defmodule Surrealix.RescueProcess do
  @moduledoc """
  This module is reponsible to execute callbacks for on_connect  / re-connect hooks.

  Since we usually like to prepare the websocket connections by executing some further commands on it,
  this blocks the websockex loop if we try it directly in the `handle_connect` callback.

  To workaround this issue, we delegate this responsibility to a `RescueProcess`, that executes
  the logic to handle connection/re-connection out-of-band. Also we need to use `GenServer.cast`, so that the
  Socket can properly continue and not be deadlocked.
  """
  use GenServer
  alias Surrealix.SocketState

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def execute_callback({socket_pid, state = %SocketState{}}) do
    GenServer.cast(__MODULE__, {:execute, socket_pid, state})
  end

  # Callbacks

  @impl true
  def init([]) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:execute, socket_pid, socket_state = %SocketState{}}, state) do
    IO.puts("******* handle_cast: execute")

    if(!is_nil(socket_state.on_connect)) do
      socket_state.on_connect.(socket_pid, socket_state)
    end

    {:noreply, state}
  end
end
