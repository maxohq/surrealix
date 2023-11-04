defmodule Surrealix.HandlerTable do
  @moduledoc false
  use GenServer

  @table __MODULE__
  @table_opts [
    :duplicate_bag,
    :public,
    :named_table,
    {:keypos, 2},
    {:read_concurrency, true}
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    _ = :ets.new(@table, @table_opts)
    {:ok, %{}}
  end

  def handlers_for_event(event) do
    case :ets.lookup(@table, event) do
      [] ->
        []

      list ->
        for {_id, event, f, config} <- list do
          {f, event, config}
        end
    end
  end

  def insert(id, events, fun, config) do
    case :ets.match(@table, {id, :_, :_, :_}) do
      [] ->
        :ets.insert(@table, {id, events, fun, config})
        :ok

      [_res] ->
        msg = """
        A handler with the id: #{id} has already been added.
        """

        error = %Surrealix.AttachError{message: msg}
        {:error, error}
    end
  end

  def remove(id) do
    :ets.match_delete(@table, {id, :_, :_, :_})
  end

  # Debug / dev functions #############
  def delete_all() do
    :ets.delete_all_objects(@table)
  end

  def all do
    :ets.tab2list(@table)
  end
end
