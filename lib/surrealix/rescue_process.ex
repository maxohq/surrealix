defmodule Surrealix.RescueProcess do
  @moduledoc """
  This module is responsible to execute callbacks for on_auth hooks, that happen after a connection is established.
  This can not be done direcly in the `handle_connect` callback, since then it blocks the execution of the WebSockex process.

  To workaround this issue, we delegate this responsibility to a `RescueProcess`, that executes those callbacks out-of-band.
  Also we need to use `GenServer.cast`, so that the Socket can properly continue and not be deadlocked.
  """
  use GenServer
  alias Surrealix.SocketState

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def execute_callback({socket_pid, state = %SocketState{}}) do
    GenServer.cast(__MODULE__, {:execute, socket_pid, state})
  end

  #################
  # Callbacks
  #################

  @impl true
  def init([]) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:execute, socket_pid, socket_state = %SocketState{}}, _state) do
    if(!is_nil(socket_state.on_auth)) do
      # set AUTH status to false, so that the busy-waiting does not trigger
      Surrealix.set_auth_ready(socket_pid, false)

      # on_auth callback used to login / and pick NS / DB
      socket_state.on_auth.(socket_pid, socket_state)

      # now reconnect live queries
      queries = SocketState.all_live_queries(socket_state)
      # we need to reset the current state of live queries, since the connection was dead anyways
      Surrealix.reset_live_queries(socket_pid)

      # now we re-establish all live queries, that we very listening to before the connection drop.
      for {sql, callback} <- queries do
        Surrealix.live_query(socket_pid, sql, callback)
      end

      # set AUTH status to true, so `Surrealix.wait_until_auth_ready(pid)` unblocks and allows further queries on the authenticated socket.
      Surrealix.set_auth_ready(socket_pid, true)
    end

    {:noreply, []}
  end
end
