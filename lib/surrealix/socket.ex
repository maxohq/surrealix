defmodule Surrealix.Socket do
  @moduledoc """
  Socket module to wrap the interactions with `WebSockex` process.
  """

  use WebSockex

  alias Surrealix.Api
  alias Surrealix.Config
  alias Surrealix.Patiently
  alias Surrealix.RescueProcess
  alias Surrealix.SocketState
  alias Surrealix.Telemetry
  alias Surrealix.Util

  require Logger

  @type base_connection_opts :: Config.socket_opts()
  @type on_start :: {:ok, pid} | {:error, term}

  @spec start(Config.socket_opts()) :: on_start()
  def start(opts \\ []) do
    generic_start(opts, :start)
  end

  @spec start_link(Config.socket_opts()) :: on_start()
  def start_link(opts \\ []) do
    generic_start(opts, :start_link)
  end

  defp generic_start(opts, fun_name) when fun_name in [:start, :start_link] do
    opts = Keyword.merge(Config.base_conn_opts(), opts)
    port = Keyword.get(opts, :port)
    hostname = Keyword.get(opts, :hostname)
    on_auth = Keyword.get(opts, :on_auth)

    state = SocketState.new(on_auth)
    url = "ws://#{hostname}:#{port}/rpc"
    apply(WebSockex, fun_name, [url, __MODULE__, state, opts])
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  def wait_until_crud_ready(pid) do
    Patiently.wait_for(fn -> SocketState.is_crud_ready(:sys.get_state(pid)) end)
  end

  def set_crud_ready(pid, value) do
    WebSockex.cast(pid, {:set_crud_ready, value})
  end

  def reset_live_queries(pid) do
    WebSockex.cast(pid, {:reset_live_queries})
  end

  def terminate(reason, state) do
    debug("terminate", reason: reason, state: state)
    exit(:normal)
  end

  def exec_method(pid, {method, args, task}, opts \\ []) do
    start_time = System.monotonic_time()
    meta = %{method: method, args: args}
    Telemetry.start(:exec_method, meta)
    id = Util.uuid(40)

    task =
      if !is_nil(task),
        do: task,
        else:
          Task.async(fn ->
            receive do
              {:ok, msg, ^id} ->
                if is_map(msg) and Map.has_key?(msg, "error"), do: {:error, msg}, else: {:ok, msg}

              {:error, reason} ->
                {:error, reason}

              e ->
                {:error, "Unknown Error #{inspect(e)}"}
            end
          end)

    WebSockex.cast(pid, {method, args, id, task})

    task_timeout = Keyword.get(opts, :timeout, Config.default_timeout())
    res = Task.await(task, task_timeout)
    Telemetry.stop(:exec_method, start_time, meta)
    res
  end

  ####################################
  # CALLBACKS
  ####################################

  def handle_connect(conn, state = %SocketState{}) do
    debug("handle_connect", state: state, conn: conn)

    if(state.on_auth) do
      RescueProcess.execute_callback({self(), state})
    end

    {:ok, state}
  end

  def handle_disconnect(connection_status_map, state) do
    attempt_number = connection_status_map.attempt_number
    to_sleep = min(Config.backoff_max(), attempt_number * Config.backoff_step())

    debug("handle_disconnect", status: connection_status_map)
    debug("handle_disconnect", "******** SLEEPING FOR #{to_sleep}ms...")
    Process.sleep(to_sleep)

    {:reconnect, state}
  end

  def handle_cast({:register_live_query, sql, query_id, callback}, state) do
    {:ok, SocketState.register_live_query(state, sql, query_id, callback)}
  end

  def handle_cast({:reset_live_queries}, state) do
    {:ok, SocketState.reset_live_queries(state)}
  end

  def handle_cast({:set_crud_ready, value}, state) do
    {:ok, SocketState.set_crud_ready(state, value)}
  end

  def handle_cast({method, args, id, task}, state) do
    debug("handle_cast", state)
    payload = Api.build_cast_payload(method, args, id)

    {:reply, {:text, payload}, SocketState.register_task(state, id, task)}
  end

  def handle_frame({_type, msg}, state) do
    json = Jason.decode!(msg)
    id = Map.get(json, "id")
    task = SocketState.get_task(state, id)

    if is_nil(task) do
      # No registered task for this ID, must be a live query update
      lq_id = get_in(json, ["result", "id"])
      lq_item = SocketState.get_live_query(state, lq_id)

      if(!is_nil(lq_item)) do
        lq_item.callback.(json, lq_id)
      end
    else
      if Process.alive?(task.pid) do
        Process.send(task.pid, {:ok, json, id}, [])
      end
    end

    {:ok, SocketState.delete_task(state, id)}
  end

  defp debug(area, data) do
    Logger.debug("[surrealix] [#{area}] #{inspect(data)}")
  end
end
