defmodule ArrayTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "Array" do
    setup [:setup_surrealix]

    test "array:complement", %{pid: pid} do
      sql = ~s|
        -- The array::complement function returns the complement of two arrays, returning a single array containing items which are not in the second array.
        RETURN array::complement([1,2,3,4], [3,4,5,6]);
      |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [1, 2]] <- parsed)
    end

    test "array::concat", %{pid: pid} do
      sql = ~s|
          -- The array::concat function merges two arrays together, returning an array which may contain duplicate values. If you want to remove duplicate values from the resulting array, then use the array::union() function
          RETURN array::concat([1,2,3,4], [3,4,5,6]);
        |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [1, 2, 3, 4, 3, 4, 5, 6]] <- parsed)
    end

    test "array::difference", %{pid: pid} do
      sql = ~s|
            -- The array::difference determines the difference between two arrays, returning a single array containing items which are not in both arrays.
            RETURN array::difference([1,2,3,4], [3,4,5,6]);
          |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [1, 2, 5, 6]] <- parsed)
    end

    test "array::distinct", %{pid: pid} do
      sql = ~s|
              -- The array::distinct function calculates the unique values in an array, returning a single array.
              RETURN array::distinct([ 1, 2, 1, 3, 3, 4 ]);
            |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [1, 2, 3, 4]] <- parsed)
    end

    test "array::distinct - 1", %{pid: pid} do
      setup_sql = ~s|
          create person:1 set name = "John", tags = ["founder", "music", "gaming"];
          create person:2 set name = "Marry", tags = ["cooking", "music", "biking"];
          create company:1 set name = "SunnyCorp", tags = ["music", "gaming", "biking", "venturing"];
        |

      sql = ~s|
        -- Select unique values from an array
        SELECT array::distinct(tags) FROM person, company;


        -- Select unique values from a nested array across an entire table
        SELECT array::group(tags) AS tags FROM person, company GROUP ALL;
      |

      {:ok, _} = Surrealix.query(pid, setup_sql)

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [
            %{"array::distinct" => ["founder", "music", "gaming"]},
            %{"array::distinct" => ["cooking", "music", "biking"]},
            %{"array::distinct" => ["music", "gaming", "biking", "venturing"]}
          ],
          ok: [%{"tags" => ["founder", "music", "gaming", "cooking", "biking", "venturing"]}]
        ] <- parsed
      )
    end

    test "array::flatten", %{pid: pid} do
      sql = ~s|
                -- The array::flatten flattens an array of arrays, returning a new array with all sub-array elements concatenated into it.
                RETURN array::flatten([ [1,2], [3, 4], 'SurrealDB', [5, 6, [7, 8]] ]);
              |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      ## [7,8] looks funny as char list
      auto_assert([ok: [1, 2, 3, 4, "SurrealDB", 5, 6, ~c""]] <- parsed)
    end

    test "array:find_index", %{pid: pid} do
      sql = ~s|
                -- The array::find_index Returns the index of the first occurrence of value in the array or null if array does not contain value
                RETURN array::find_index(['a', 'b', 'c', 'b', 'a'], 'b');

                -- should be empty
                RETURN array::find_index(['a', 'b', 'c', 'b', 'a'], 'X');
              |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: 1, ok: nil] <- parsed)
    end

    test "array::group", %{pid: pid} do
      sql = ~s|
        -- The array::group function flattens and returns the unique items in an array.
        RETURN array::group([1, 2, 3, 4, [3,5,6], [2,4,5,6], 7, 8, 8, 9]);
      |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [1, 2, 3, 4, 5, 6, 7, 8, 9]] <- parsed)
    end

    test "array::remove", %{pid: pid} do
      sql = ~s|
          -- The array::remove function removes an item from a specific position in an array.
          RETURN array::remove([1,2,3,4,5], 2);
        |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [1, 2, 4, 5]] <- parsed)
    end

    test "array::reverse", %{pid: pid} do
      sql = ~s|
            -- The array::reverse function appends a value to the end of an array.
            RETURN array::reverse([ 1, 2, 3, 4, 5 ]);
          |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [5, 4, 3, 2, 1]] <- parsed)
    end

    test "array::union", %{pid: pid} do
      sql = ~s|
              -- The array::union function combines two arrays together, removing duplicate values, and returning a single array.
              RETURN array::union([1,2,1,6], [1,3,4,5,6]);

            |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [1, 2, 6, 3, 4, 5]] <- parsed)
    end

    test "array::sort - asc / desc", %{pid: pid} do
      sql = ~s|
        -- The array::union function combines two arrays together, removing duplicate values, and returning a single array.
        RETURN array::sort::asc(array::union([1,2,1,6], [1,3,4,5,6]));
        RETURN array::sort::desc(array::union([1,2,1,6], [1,3,4,5,6]));
      |
      parsed = Surrealix.query(pid, sql) |> extract_res_list()
      auto_assert([ok: [1, 2, 3, 4, 5, 6], ok: [6, 5, 4, 3, 2, 1]] <- parsed)
    end
  end
end
