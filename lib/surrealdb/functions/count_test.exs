defmodule CountTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "Count" do
    setup [:setup_surrealix]

    test "count - filter / group by", %{pid: pid} do
      sql = ~s|
        SELECT
            country,
            count(age > 30) AS total
        FROM [
            { age: 33, country: 'GBR' },
            { age: 45, country: 'GBR' },
            { age: 39, country: 'USA' },
            { age: 29, country: 'GBR' },
            { age: 25, country: 'USA' },
            { age: 66, country: 'GER' },
            { age: 43, country: 'USA' }
        ]
        GROUP BY country;
        |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [
            %{"country" => "GBR", "total" => 2},
            %{"country" => "GER", "total" => 1},
            %{"country" => "USA", "total" => 2}
          ]
        ] <- parsed
      )
    end
  end
end
