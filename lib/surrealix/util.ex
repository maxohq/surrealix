defmodule Surrealix.Util do
  @moduledoc """
  Some generic utility functions
  """

  @doc """
  A basic check to make sure the SQL statement is indeed a live query.
  Proper check would require parsing the SQL statement and is outside of scope for this library.
  """
  def is_live_query_stmt(sql) do
    sql = String.downcase(sql)
    String.contains?(sql, "live select")
  end

  @doc """
  A small random string generator
  """
  def uuid(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
