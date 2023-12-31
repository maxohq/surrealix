defmodule Surrealix.SocketState do
  @moduledoc """
  SocketState module makes testing the State transitions for Socket much simpler
  """
  use Surrealix.Accessible
  alias Surrealix.SocketState

  @doc """
    - `pending`: Pending requests map:  id => task
    - `lq_running`: live_queries map:  id => %{sql: sql}
    - `lq_sql`: live_queries MapSet with queries to register after re-connection
  """
  defstruct pending: %{},
            lq_running: %{},
            lq_sql: MapSet.new(),
            auth_ready: false,
            on_auth: nil

  def new(), do: %SocketState{}
  def new(on_auth), do: %SocketState{on_auth: on_auth}

  def set_auth_ready(state = %SocketState{}, value) do
    put_in(state, [:auth_ready], value)
  end

  def is_auth_ready(state = %SocketState{}) do
    state.auth_ready == true
  end

  @doc """
  Register a task for a particular request ID
  """
  def register_task(state = %SocketState{}, id, task) do
    put_in(state, [:pending, id], task)
  end

  @doc """
  Get a task for a particular request ID
  """
  def get_task(state = %SocketState{}, id) do
    get_in(state, [:pending, id])
  end

  @doc """
  Remove a task for a particular request ID
  """
  def delete_task(state = %SocketState{}, id) do
    {_val, state} = pop_in(state, [:pending, id])
    state
  end

  @doc """
  Register a SQL statement for a particular LiveQuery ID
  """
  def register_live_query(state = %SocketState{}, sql, query_id, callback) do
    lq_sql = MapSet.put(state.lq_sql, {sql, callback})
    item = %{sql: sql, query_id: query_id, callback: callback}

    state
    |> put_in([:lq_running, query_id], item)
    |> Map.put(:lq_sql, lq_sql)
  end

  @doc """
  Get map that describes a particular LiveQuery ID (SQL / ID / etc)
  """
  def get_live_query(state = %SocketState{}, query_id) do
    state
    |> get_in([:lq_running, query_id])
  end

  @doc """
  Remove a LiveQuery by ID
  """
  def delete_live_query_by_id(state = %SocketState{}, query_id) do
    {item, state} = pop_in(state, [:lq_running, query_id])

    if item do
      lq_sql = MapSet.delete(state.lq_sql, {item.sql, item.callback})

      state
      |> Map.put(:lq_sql, lq_sql)
    else
      state
    end
  end

  @doc """
  Remove a LiveQuery by SQL
  """
  def delete_live_query_by_sql(state = %SocketState{}, sql) do
    found = Enum.find(state.lq_running, fn {_id, value} -> Map.get(value, :sql) == sql end)

    if !is_nil(found) do
      {key, item} = found
      lq_running = Map.delete(state.lq_running, key)
      lq_sql = MapSet.delete(state.lq_sql, {item.sql, item.callback})
      Map.put(state, :lq_running, lq_running) |> Map.put(:lq_sql, lq_sql)
    else
      state
    end
  end

  def reset_live_queries(state = %SocketState{}) do
    Map.put(state, :lq_running, %{}) |> Map.put(:lq_sql, MapSet.new())
  end

  @doc """
  Currently registered LiveQueries
  """
  def all_live_queries(state = %SocketState{}) do
    state.lq_sql |> MapSet.to_list()
  end
end
