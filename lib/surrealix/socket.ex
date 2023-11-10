## **** GENERATED CODE! see gen/src/SocketGenerator.ts for details. ****

defmodule Surrealix.Socket do
  use WebSockex

  alias Surrealix.Config
  alias Surrealix.Telemetry
  alias Surrealix.SocketState
  alias Surrealix.Util
  alias Surrealix.Api

  require Logger

  @type base_connection_opts :: Config.socket_opts()

  @spec start(Config.socket_opts()) :: WebSockex.on_start()
  def start(opts \\ []) do
    generic_start(opts, :start)
  end

  @spec start_link(Config.socket_opts()) :: WebSockex.on_start()
  def start_link(opts \\ []) do
    generic_start(opts, :start_link)
  end

  defp generic_start(opts, fun_name) do
    opts = Keyword.merge(Config.base_conn_opts(), opts)

    hostname = Keyword.get(opts, :hostname)
    port = Keyword.get(opts, :port)

    apply(WebSockex, fun_name, [
      "ws://#{hostname}:#{port}/rpc",
      __MODULE__,
      SocketState.new(),
      opts
    ])
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  def terminate(reason, state) do
    IO.puts("Socket terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")
    exit(:normal)
  end

  def handle_cast({:register_lq, sql, query_id}, state) do
    state = SocketState.add_lq(state, sql, query_id)
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
      Surrealix.Dispatch.execute([:live_query, lq_id], json)
    else
      if Process.alive?(task.pid) do
        Process.send(task.pid, {:ok, json, id}, [])
      end
    end

    {:ok, SocketState.delete_task(state, id)}
  end

  def exec_method(pid, {method, args}, opts \\ []) do
    start_time = System.monotonic_time()
    meta = %{method: method, args: args}
    Telemetry.start(:exec_method, meta)
    id = Util.uuid(40)

    task =
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

    args = Keyword.merge([__receiver__: task], args)
    WebSockex.cast(pid, {method, args, id, task})

    task_timeout = Keyword.get(opts, :timeout, :infinity)
    res = Task.await(task, task_timeout)
    Telemetry.stop(:exec_method, start_time, meta)
    res
  end
end
