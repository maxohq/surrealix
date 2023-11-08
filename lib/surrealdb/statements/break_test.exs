defmodule BreakTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "Break" do
    setup [:setup_surrealix]

    test "for - create / BREAK", %{pid: pid} do
      sql = """
      -- Create a person for everyone in the array
      FOR $num IN [1, 2, 3, 4, 5, 6, 7, 8, 9] {
        CREATE type::thing('person', $num) CONTENT {
            name: $num
        };
        IF ($num > 5) {
            BREAK;
        };
      };

      select * from person;
      """

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: nil,
          ok: [
            %{"id" => "person:1", "name" => 1},
            %{"id" => "person:2", "name" => 2},
            %{"id" => "person:3", "name" => 3},
            %{"id" => "person:4", "name" => 4},
            %{"id" => "person:5", "name" => 5},
            %{"id" => "person:6", "name" => 6}
          ]
        ] <- parsed
      )
    end
  end
end
