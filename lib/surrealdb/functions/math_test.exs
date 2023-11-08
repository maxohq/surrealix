defmodule MathTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "math" do
    setup [:setup_surrealix]

    test "math::min with select", %{pid: pid} do
      setup_sql = ~s|
        create user:1 set age = 10;
        create user:2 set age = 20;
        create user:3 set age = 40;
      |
      sql = ~s|
        select math::min(age) as min from user group all;
        select math::max(age) as max from user group all;
        select math::median(age) as median from user group all;
        select math::mean(age) as mean from user group all;
        select math::sum(age) as sum from user group all;
        select math::top(age, 2) as top_2 from user group all;
        select math::variance(age) as variance  from user group all;
      |
      {:ok, _} = Surrealix.query(pid, setup_sql)
      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [%{"min" => 10}],
          ok: [%{"max" => 40}],
          ok: [%{"median" => 20.0}],
          ok: [%{"mean" => 23.333333333333332}],
          ok: [%{"sum" => 70}],
          ok: [%{"top_2" => [20, 40]}],
          ok: [%{"variance" => 233.33333333333334}]
        ] <- parsed
      )
    end
  end
end
