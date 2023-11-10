defmodule Surrealix.Test do
  use ExUnit.Case, async: true
  import TestSupport

  describe "basic API" do
    setup [:setup_surrealix]

    test "insert / query", %{pid: pid} do
      Surrealix.insert(pid, "user", %{id: "marcus", name: "Marcus Aurelius"})
      res = Surrealix.query(pid, "select * from user:marcus") |> extract_res(0)
      assert res == [%{"id" => "user:marcus", "name" => "Marcus Aurelius"}]
    end

    test "insert / update / merge / query ", %{pid: pid} do
      Surrealix.insert(pid, "user", %{id: "marcus", name: "Marcus Aurelius"})
      res = Surrealix.query(pid, "select * from user:marcus") |> extract_res(0)
      assert res == [%{"id" => "user:marcus", "name" => "Marcus Aurelius"}]
      Surrealix.update(pid, "user", %{id: "marcus", name: "Marcus Aurelius - 3"})
      Surrealix.merge(pid, "user", %{age: 44})
      res = Surrealix.query(pid, "select * from user:marcus") |> extract_res(0)
      assert res == [%{"id" => "user:marcus", "name" => "Marcus Aurelius - 3", "age" => 44}]
    end
  end

  describe "live_query" do
    setup [:setup_surrealix]

    test "basic validation that SQL stmt is a live query", %{pid: pid} do
      {:error, "Not a live query: `SELECT * FROM user;`!"} =
        Surrealix.live_query(pid, "SELECT * FROM user;", fn _event, _data, _config ->
          IO.puts("never reached!")
        end)
    end

    test "callbacks are properly executed", %{pid: pid} do
      testpid = self()

      {:ok, _} =
        Surrealix.live_query(pid, "LIVE SELECT * FROM user;", fn _event, data, _config ->
          send(testpid, {:lq, data})
        end)

      {:ok, %{"result" => [%{"id" => "user:marcus", "name" => "Marcus Aurelius"}]}} =
        Surrealix.insert(pid, "user", %{id: "marcus", name: "Marcus Aurelius"})

      assert_receive {:lq, data}

      %{
        "result" => %{
          "action" => "CREATE",
          "id" => _lq_id,
          "result" => %{"id" => "user:marcus", "name" => "Marcus Aurelius"}
        }
      } = data

      res = Surrealix.query(pid, "select * from user:marcus") |> extract_res(0)
      assert res == [%{"id" => "user:marcus", "name" => "Marcus Aurelius"}]

      {:ok, %{"result" => %{"age" => 44, "id" => "user:marcus", "name" => "Marcus Aurelius"}}} =
        Surrealix.merge(pid, "user:marcus", %{age: 44})

      assert_receive {:lq, data2}

      %{
        "result" => %{
          "action" => "UPDATE",
          "result" => %{"age" => 44, "id" => "user:marcus", "name" => "Marcus Aurelius"}
        }
      } = data2

      res = Surrealix.query(pid, "select * from user:marcus") |> extract_res(0)
      assert res == [%{"id" => "user:marcus", "name" => "Marcus Aurelius", "age" => 44}]

      {:ok, _} = Surrealix.delete(pid, "user:marcus")
      assert_receive {:lq, data3}

      %{
        "result" => %{
          "action" => "DELETE",
          "result" => "user:marcus"
        }
      } = data3

      res = Surrealix.query(pid, "select * from user:marcus") |> extract_res(0)
      assert res == []
    end
  end
end
