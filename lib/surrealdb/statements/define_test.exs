defmodule DefineTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "Define :: Function" do
    setup [:setup_surrealix]

    test "define / function with SQL", %{pid: pid} do
      sql = ~S|
        -- It is necessary to prefix the name of your function with "fn::"
        -- This indicates that it's a custom function
        DEFINE FUNCTION fn::greet($name: string) {
            RETURN "Hello, " + $name + "!";
        };

        RETURN fn::greet("John");
        |

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert([ok: nil, ok: "Hello, John!"] <- parsed)
    end

    test "define / function with JS", %{pid: pid} do
      sql = ~S|
        DEFINE FUNCTION fn::js_greet($name: string) {
          RETURN function($name) {
            const [name] = arguments;
	          return `${name} is awesome! I'm a JS function with arguments!`;
          }
        };

        RETURN fn::js_greet("John");
        RETURN fn::js_greet("Marry");
      |

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: nil,
          ok: "John is awesome! I'm a JS function with arguments!",
          ok: "Marry is awesome! I'm a JS function with arguments!"
        ] <- parsed
      )
    end
  end

  describe "Define :: Index" do
    setup [:setup_surrealix]

    test "define / index with SQL", %{pid: pid} do
      ##
      sql_setup = ~S|
        -- https://surrealdb.com/docs/surrealql/statements/define/analyzer

        -- we create an analyzer that tokenizes by class (digit / words / punctuation),
        -- and filters by stemming with german stemmer and building edgengram tokens (for partial matches)

        DEFINE ANALYZER german TOKENIZERS class FILTERS snowball(german), edgengram(1,3);
        -- now we use this analyzer on the book table for title columns (could be more)
        DEFINE INDEX idx_book_title ON TABLE book COLUMNS title SEARCH ANALYZER german BM25 HIGHLIGHTS;
        DEFINE INDEX idx_book_desc ON TABLE book COLUMNS description SEARCH ANALYZER german BM25 HIGHLIGHTS;
        CREATE book:1 set title = "Rust Web Development";
        CREATE book:2 set description = "Ruby Web Development";
      |
      sql = ~S|
        SELECT * FROM book WHERE title @@ 'rust web' or description @@ 'rust web';
        SELECT * FROM book WHERE title @@ 'rust dev';
        SELECT * FROM book WHERE title or description @@ 'ruby dev';
      |

      {:ok, _} = Surrealix.query(pid, sql_setup)
      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [%{"id" => "book:1", "title" => "Rust Web Development"}],
          ok: [%{"id" => "book:1", "title" => "Rust Web Development"}],
          ok: [%{"description" => "Ruby Web Development", "id" => "book:2"}]
        ] <- parsed
      )
    end
  end
end
