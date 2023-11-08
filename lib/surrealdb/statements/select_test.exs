defmodule SelectTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  @moduledoc """
  - https://surrealdb.com/docs/surrealql/statements/select
  """

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
        create person:1 set name = "John", email = "a@b.com", age = 17;
        create person:2 set name = "Marry", email = "b@b.com", age = 18;
        create person:3 set name = "Chris", email = "c@b.com", age = 20;
      |

      sql = ~s|
        -- This command first performs a subquery, which selects all 'person' records and adds a
        -- computed 'adult' field that is true if the person's 'age' is 18 or older.
        -- The main query then selects all records from this subquery where 'adult' is true.
        SELECT * FROM (SELECT *, age >= 18 AS adult FROM person) WHERE adult = true;
      |

      {:ok, _} = Surrealix.query(pid, setup_sql)

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [
            %{
              "adult" => true,
              "age" => 18,
              "email" => "b@b.com",
              "id" => "person:2",
              "name" => "Marry"
            },
            %{
              "adult" => true,
              "age" => 20,
              "email" => "c@b.com",
              "id" => "person:3",
              "name" => "Chris"
            }
          ]
        ] <- parsed
      )
    end

    test "select - from multiple tables", %{pid: pid} do
      setup_sql = ~s|
        create person:1 set name = "John", email = "a@b.com", age = 17;
        create person:2 set name = "Marry", email = "b@b.com", age = 18;
        create admin:1 set name = "Chris", email = "c@b.com", age = 20;
      |

      sql = ~s|
      -- This command selects all records from both 'user' and 'admin' tables.
      SELECT * FROM person, admin;
      |

      {:ok, _} = Surrealix.query(pid, setup_sql)

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [
            %{"age" => 17, "email" => "a@b.com", "id" => "person:1", "name" => "John"},
            %{"age" => 18, "email" => "b@b.com", "id" => "person:2", "name" => "Marry"},
            %{"age" => 20, "email" => "c@b.com", "id" => "admin:1", "name" => "Chris"}
          ]
        ] <- parsed
      )
    end

    test "select - filtering on graph edges", %{pid: pid} do
      setup_sql = ~s|
        create org:1 set name = "Org1";
        create org:2 set name = "Org2";
        create org:3 set name = "Org3";
        create org:4 set name = "Org4";
        create profile:1 set name = "Prof1";
        create profile:2 set name = "Prof2";
        create profile:3 set name = "Prof3";


        RELATE profile:1->experience->org:1
	        SET time.started = time::now()
        ;
        RELATE profile:1->experience->org:2
	        SET time.started = time::now()
        ;
        RELATE profile:1->experience->org:3
	        SET time.started = time::now()
        ;
        RELATE profile:1->experience->org:4
	        SET time.started = time::now()
        ;

        RELATE profile:2->experience->org:1
	        SET time.started = time::now()
        ;
        RELATE profile:2->experience->org:2
	        SET time.started = time::now()
        ;

        RELATE profile:3->experience->org:1
	        SET time.started = time::now()
        ;
      |

      sql = ~s|
      -- Conditional filtering based on graph edges
      SELECT * FROM profile WHERE count(->experience->org) > 3;
      SELECT * FROM profile WHERE count(->experience->org) > 1;

      -- include the count into result
      SELECT *, count(->experience->org) as exp FROM profile WHERE count(->experience->org) = 1;
      |

      {:ok, _} = Surrealix.query(pid, setup_sql)

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [%{"id" => "profile:1", "name" => "Prof1"}],
          ok: [
            %{"id" => "profile:1", "name" => "Prof1"},
            %{"id" => "profile:2", "name" => "Prof2"}
          ],
          ok: [%{"exp" => 1, "id" => "profile:3", "name" => "Prof3"}]
        ] <- parsed
      )
    end
  end
end
