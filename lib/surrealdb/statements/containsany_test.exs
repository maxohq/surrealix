defmodule ContainsAnyTest do
  use ExUnit.Case, async: true
  use MnemeDefaults
  import TestSupport

  @moduledoc """
  - https://surrealdb.com/docs/surrealql/statements/select
  """

  describe "CONTAINSANY" do
    setup [:setup_surrealix]

    test "select - CONTAINSANY", %{pid: pid} do
      setup_sql = ~s|
          create person:1 set name = "John", tags = ["founder", "music", "gaming"];
          create person:2 set name = "Marry", tags = ["cooking", "music", "biking"];
          create company:1 set name = "SunnyCorp", tags = ["music", "gaming", "biking"];
        |

      sql = ~s|
          -- wrap response in a map
          SELECT * FROM person, company WHERE tags CONTAINSANY ["music"];
          SELECT * FROM person, company WHERE tags CONTAINSANY ["gaming"];
          SELECT * FROM person, company WHERE tags CONTAINSANY ["biking"];
          SELECT * FROM person, company WHERE tags CONTAINSANY ["cooking"];
      |

      {:ok, _} = Surrealix.query(pid, setup_sql)

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [
            %{"id" => "person:1", "name" => "John", "tags" => ["founder", "music", "gaming"]},
            %{"id" => "person:2", "name" => "Marry", "tags" => ["cooking", "music", "biking"]},
            %{"id" => "company:1", "name" => "SunnyCorp", "tags" => ["music", "gaming", "biking"]}
          ],
          ok: [
            %{"id" => "person:1", "name" => "John", "tags" => ["founder", "music", "gaming"]},
            %{"id" => "company:1", "name" => "SunnyCorp", "tags" => ["music", "gaming", "biking"]}
          ],
          ok: [
            %{"id" => "person:2", "name" => "Marry", "tags" => ["cooking", "music", "biking"]},
            %{"id" => "company:1", "name" => "SunnyCorp", "tags" => ["music", "gaming", "biking"]}
          ],
          ok: [%{"id" => "person:2", "name" => "Marry", "tags" => ["cooking", "music", "biking"]}]
        ] <- parsed
      )
    end
  end
end
