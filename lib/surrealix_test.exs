defmodule Surrealix.Test do
  use ExUnit.Case
  import TestSupport

  describe "basic case" do
    test "works" do
      with_cleanup(fn pid ->
        Surrealix.insert(pid, "user", %{id: "marcus", name: "Marcus Aurelius"})
        res = Surrealix.query(pid, "select * from user:marcus") |> extract_res(0)
        assert res == [%{"id" => "user:marcus", "name" => "Marcus Aurelius"}]
      end)
    end
  end
end
