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
end
