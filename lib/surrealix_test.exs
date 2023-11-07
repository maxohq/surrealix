defmodule Surrealix.Test do
  use ExUnit.Case
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
end
