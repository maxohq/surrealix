defmodule Surrealix.Socket do
  @moduledoc """
  Socket module to wrap the interactions with `WebSockex` process.
  """

  use WebSockex

  alias Surrealix.Api
  alias Surrealix.Config
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
    on_connect = Keyword.get(opts, :on_connect)
    hostname = Keyword.get(opts, :hostname)
    port = Keyword.get(opts, :port)

    state = SocketState.new(on_connect)
    url = "ws://#{hostname}:#{port}/rpc"
    apply(WebSockex, fun_name, [url, __MODULE__, state, opts])
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  def terminate(reason, state) do
    Logger.debug("Socket terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")
    exit(:normal)
  end

  def handle_disconnect(connection_status_map, state) do
    IO.inspect(%{status: connection_status_map}, label: "DISCONNECT")
    attempt_number = connection_status_map.attempt_number
    to_sleep = attempt_number * 5
    IO.puts("******** SLEEPING FOR #{to_sleep}ms...")

    Process.sleep(to_sleep)
    {:reconnect, state}
  end

  def handle_connect(conn, state = %SocketState{}) do
    IO.inspect(%{state: state, conn: conn}, label: "CONNECT")

    if(state.on_connect) do
      IO.inspect(%{pid: self(), state: state, conn: conn}, label: "***** ON_CONNECT callback")
      Surrealix.RescueProcess.execute_callback({self(), state})
    end

    {:ok, state}
  end

  def handle_cast({:register_lq, sql, query_id, callback}, state) do
    state = SocketState.add_lq(state, sql, query_id, callback)
    {:ok, state}
  end

  def handle_cast({method, args, id, task}, state) do
    Logger.debug("[surrealix] [handle_cast] #{inspect(state)}")
    payload = Api.build_cast_payload(method, args, id)
    state = SocketState.add_task(state, id, task)
    frame = {:text, payload}
    {:reply, frame, state}
  end

  def handle_frame({_type, msg}, state) do
    json = Jason.decode!(msg)
    id = Map.get(json, "id")
    task = SocketState.get_task(state, id)

    if is_nil(task) do
      # No registered task for this ID, must be a live query update
      lq_id = get_in(json, ["result", "id"])
      lq_item = SocketState.get_lq(state, lq_id)

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
end
