defmodule SelectTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "Select" do
    setup [:setup_surrealix]

    test "select - basic", %{pid: pid} do
      setup_sql = ~s|
        create person:1 set name = "John", email = "a@b.com", address = {city: "Rome"};
        create person:2 set name = "Marry", email = "b@b.com", address = {city: "Barcelona"};
        create company:1 set name = "SunnyCorp", email = "c@b.com", address = {city: "Lost City", street: "Road to heaven"};
      |

      sql = ~s|
        -- wrap response in a map
        return {idx: 1, res: select * from person};

        -- select different things in a single query
        return {idx: 2, res: select * from person:1, company:1};
      |

      {:ok, _} = Surrealix.query(pid, setup_sql)

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: %{
            "idx" => 1,
            "res" => [
              %{
                "address" => %{"city" => "Rome"},
                "email" => "a@b.com",
                "id" => "person:1",
                "name" => "John"
              },
              %{
                "address" => %{"city" => "Barcelona"},
                "email" => "b@b.com",
                "id" => "person:2",
                "name" => "Marry"
              }
            ]
          },
          ok: %{
            "idx" => 2,
            "res" => [
              %{
                "address" => %{"city" => "Rome"},
                "email" => "a@b.com",
                "id" => "person:1",
                "name" => "John"
              },
              %{
                "address" => %{"city" => "Lost City", "street" => "Road to heaven"},
                "email" => "c@b.com",
                "id" => "company:1",
                "name" => "SunnyCorp"
              }
            ]
          }
        ] <- parsed
      )
    end

    test "select - subselect on computed field", %{pid: pid} do
      setup_sql = ~s|
        create person:1 set name = "John", email = "a@b.com", address = {city: "Rome"};
        create person:2 set name = "Marry", email = "b@b.com", address = {city: "Barcelona"};
        create company:1 set name = "SunnyCorp", email = "c@b.com", address = {city: "Lost City", street: "Road to heaven"};
      |

      sql = ~s|
        -- This command first performs a subquery, which selects all 'person' records and adds a
        -- computed 'adult' field that is true if the person's 'age' is 18 or older.
        -- The main query then selects all records from this subquery where 'adult' is true.
        SELECT * FROM (SELECT *, age >= 18 AS adult FROM person) WHERE adult = true;
      |

      {:ok, _} = Surrealix.query(pid, setup_sql)

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert([ok: []] <- parsed)
    end
  end
end
