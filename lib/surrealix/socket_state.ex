defmodule Surrealix.SocketState do
  @moduledoc """
  SocketState module makes testing the State transitions for Socket much simpler
  """
  use Surrealix.Accessible
  alias Surrealix.SocketState

  @doc """
    - `pending`: Pending requests map:  id => task
    - `lq_running`: live_queries map:  id => %{sql: sql}
    - `lq_sql`: live_queries SET with queries to register after re-connection
  """
  defstruct pending: %{},
            lq_running: %{},
            lq_sql: MapSet.new()

  def new(), do: %SocketState{}

  @doc """
  Register a task for a particular request ID
  """
  def add_task(state = %SocketState{}, id, task) do
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
  def add_lq(state = %SocketState{}, sql, query_id) do
    lq_sql = MapSet.put(state.lq_sql, sql)
    item = %{sql: sql, query_id: query_id}

    state
    |> put_in([:lq_running, query_id], item)
    |> Map.put(:lq_sql, lq_sql)
  end

  @doc """
  Get map that describes a particular LiveQuery ID (SQL / ID / etc)
  """
  def get_lq(state = %SocketState{}, query_id) do
    state
    |> get_in([:lq_running, query_id])
  end

  @doc """
  Remove a LiveQuery by ID
  """
  def delete_lq_by_id(state = %SocketState{}, query_id) do
    {item, state} = pop_in(state, [:lq_running, query_id])

    if item do
      lq_sql = MapSet.delete(state.lq_sql, item.sql)

      state
      |> Map.put(:lq_sql, lq_sql)
    else
      state
    end
  end

  @doc """
  Remove a LiveQuery by SQL
  """
  def delete_lq_by_sql(state = %SocketState{}, sql) do
    lq_running =
      Enum.reject(state.lq_running, fn {_id, value} -> Map.get(value, :sql) == sql end)
      |> Map.new()

    lq_sql = MapSet.delete(state.lq_sql, sql)
    Map.put(state, :lq_running, lq_running) |> Map.put(:lq_sql, lq_sql)
  end

  @doc """
  Currently registered LiveQueries
  """
  def all_lq(state = %SocketState{}) do
    state.lq_sql |> MapSet.to_list()
  end
end
