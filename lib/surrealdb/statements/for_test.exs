defmodule ForTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "For" do
    setup [:setup_surrealix]

    test "for - create", %{pid: pid} do
      sql = """
      FOR $name IN ['John', 'Mike'] {
        CREATE type::thing('person', $name) CONTENT {
            name: $name
        };
      };

      select * from person;
      """

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: nil,
          ok: [
            %{"id" => "person:John", "name" => "John"},
            %{"id" => "person:Mike", "name" => "Mike"}
          ]
        ] <- parsed
      )
    end

    test "for - update", %{pid: pid} do
      sql = """
      create person:1 set age = 19;
      create person:2 set age = 17;
      create person:3 set age = 18;
      FOR $person IN (SELECT VALUE id FROM person WHERE age >= 18) {
        UPDATE $person SET can_vote = true;
      };
      select * from person where can_vote = true;
      """

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [%{"age" => 19, "id" => "person:1"}],
          ok: [%{"age" => 17, "id" => "person:2"}],
          ok: [%{"age" => 18, "id" => "person:3"}],
          ok: nil,
          ok: [
            %{"age" => 19, "can_vote" => true, "id" => "person:1"},
            %{"age" => 18, "can_vote" => true, "id" => "person:3"}
          ]
        ] <- parsed
      )
    end
  end
end
