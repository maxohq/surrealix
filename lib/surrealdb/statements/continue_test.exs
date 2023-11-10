defmodule ContinueTest do
  use ExUnit.Case, async: true
  use MnemeDefaults
  import TestSupport

  describe "continue" do
    setup [:setup_surrealix]

    test "for - update / continue", %{pid: pid} do
      sql_setup = ~s|
        create person:1 set age = 17;
        create person:2 set age = 18;
        create person:3 set age = 19;
        create person:4 set age = 20;
      |
      sql = ~s|
      FOR $person IN (SELECT id, age FROM person) {
        IF ($person.age < 18) {
            CONTINUE;
        };

        UPDATE $person.id SET can_vote = true;
      };

      select * from person where can_vote = true;
      |
      {:ok, _} = Surrealix.query(pid, sql_setup)

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
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
