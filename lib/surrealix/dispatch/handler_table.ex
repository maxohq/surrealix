defmodule Surrealix.Dispatch.HandlerTable do
  @moduledoc false
  use GenServer

  @tab __MODULE__

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def handlers_for_event(event) do
    case :ets.lookup(@tab, event) do
      [] ->
        []

      list ->
        for {_id, event, f, config} <- list do
          {f, event, config}
        end
    end
  end

  def insert(id, events, fun, config) do
    GenServer.call(__MODULE__, {:insert, id, events, fun, config})
  end

  # This is only used for testing and development purposes
  def delete_all do
    GenServer.call(__MODULE__, :delete_all)
  end

  def init(_args) do
    tab_opts = [
      :duplicate_bag,
      :protected,
      :named_table,
      {:keypos, 2},
      {:read_concurrency, true}
    ]

    _ = :ets.new(@tab, tab_opts)

    state = %{
      tab: @tab
    }

    {:ok, state}
  end

  def handle_call({:insert, id, events, fun, config}, _from, state) do
    case :ets.match(state.tab, {id, :_, :_, :_}) do
      [] ->
        :ets.insert(state.tab, {id, events, fun, config})
        {:reply, :ok, state}

      [_] ->
        msg = """
        A handler with the id: #{id} has already been added.
        """

        error = %Surrealix.Dispatch.AttachError{message: msg}
        {:reply, {:error, error}, state}
    end
  end

  def handle_call(:delete_all, _from, state) do
    :ets.delete_all_objects(state.tab)

    {:reply, :ok, state}
  end
end
