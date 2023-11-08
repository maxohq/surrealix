defmodule BreakTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "continue" do
    setup [:setup_surrealix]

    test "for - update / continue", %{pid: pid} do
      sql = ~s|
      create person:1 set age = 17;
      create person:2 set age = 18;
      create person:3 set age = 19;
      create person:4 set age = 20;

      FOR $person IN (SELECT id, age FROM person) {
        IF ($person.age < 18) {
            CONTINUE;
        };

        UPDATE $person.id SET can_vote = true;
      };

      select * from person where can_vote = true;
      |

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [%{"age" => 17, "id" => "person:1"}],
          ok: [%{"age" => 18, "id" => "person:2"}],
          ok: [%{"age" => 19, "id" => "person:3"}],
          ok: [%{"age" => 20, "id" => "person:4"}],
          ok: nil,
          ok: [
            %{"age" => 18, "can_vote" => true, "id" => "person:2"},
            %{"age" => 19, "can_vote" => true, "id" => "person:3"},
            %{"age" => 20, "can_vote" => true, "id" => "person:4"}
          ]
        ] <- parsed
      )
    end
  end
end
