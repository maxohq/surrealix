defmodule Surrealix.SocketStateTest do
  use ExUnit.Case, async: true

  alias Surrealix.SocketState

  def dummy_callback(), do: fn -> nil end

  describe "tasks" do
    test "add_task / get_task / delete_task" do
      state = SocketState.new()
      state = state |> SocketState.add_task("111", :task1)
      assert SocketState.get_task(state, "111") == :task1

      state = SocketState.delete_task(state, "111")
      assert SocketState.get_task(state, "111") == nil
    end

    test "delete accepts non-existing ids" do
      state = SocketState.new()
      state = state |> SocketState.add_task("111", :task1)
      state = SocketState.delete_task(state, "1111")
      assert SocketState.get_task(state, "111") == :task1
    end
  end

  describe "lq" do
    test "add_lq / get_lq" do
      state = SocketState.new()
      cb = dummy_callback()
      state = state |> SocketState.add_lq("select * from person", "11-22", cb)

      assert SocketState.get_lq(state, "11-22") == %{
               callback: cb,
               query_id: "11-22",
               sql: "select * from person"
             }
    end

    test "all_lq" do
      state = SocketState.new()
      cb = dummy_callback()
      state = state |> SocketState.add_lq("select * from person", "11-22", cb)
      state = state |> SocketState.add_lq("select * from user", "11-23", cb)

      assert SocketState.all_lq(state) == [
               {"select * from person", cb},
               {"select * from user", cb}
             ]
    end

    test "delete_lq_by_id" do
      state = SocketState.new()
      cb = dummy_callback()
      state = state |> SocketState.add_lq("select * from person", "11-22", cb)
      state = state |> SocketState.add_lq("select * from user", "11-23", cb)

      assert SocketState.all_lq(state) == [
               {"select * from person", cb},
               {"select * from user", cb}
             ]

      state = state |> SocketState.delete_lq_by_id("11-23")
      assert SocketState.all_lq(state) == [{"select * from person", cb}]
      assert SocketState.get_lq(state, "11-23") == nil
    end

    test "delete_lq_by_sql" do
      state = SocketState.new()
      cb = dummy_callback()
      state = state |> SocketState.add_lq("select * from person", "11-22", cb)
      state = state |> SocketState.add_lq("select * from user", "11-23", cb)

      assert SocketState.all_lq(state) == [
               {"select * from person", cb},
               {"select * from user", cb}
             ]

      state = SocketState.delete_lq_by_sql(state, "select * from person")
      assert SocketState.all_lq(state) == [{"select * from user", cb}]
      assert SocketState.get_lq(state, "11-22") == nil

      assert SocketState.get_lq(state, "11-23") == %{
               query_id: "11-23",
               sql: "select * from user",
               callback: cb
             }
    end
  end
end
