defmodule IfElseTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "If / Else" do
    setup [:setup_surrealix]

    test "if / else - if branch", %{pid: pid} do
      sql = """
      LET $name = "john";
      LET $age = 20;

      IF $name = "john" {
        return "name matched"
      } else if $age > 10 {
        return "age matched"
      };
      """

      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: nil, ok: nil, ok: "name matched"] <- parsed)
    end

    test "if / else - else branch", %{pid: pid} do
      sql = """
      LET $name = "john";
      LET $age = 20;

      IF $name = "NOBODY" {
        return "name matched"
      } else if $age > 10 {
        return "age matched"
      }
      """

      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: nil, ok: nil, ok: "age matched"] <- parsed)
    end
  end
end
