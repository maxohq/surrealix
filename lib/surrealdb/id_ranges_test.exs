defmodule IdRangesTest do
  use ExUnit.Case, async: true
  use MnemeDefaults
  import TestSupport

  describe "Id Ranges" do
    setup [:setup_surrealix]

    test "", %{pid: pid} do
      sql_setup = ~s|
      create app:[902, 'APP1', 1] set idx = 1;
      create app:[902, 'APP1', 2] set idx = 2;
      create app:[902, 'APP1', 3] set idx = 3;

      create app:[906, 'APP1', 2] set idx = 4;
      create app:[906, 'APP1', 4] set idx = 5;
      create app:[906, 'APP1', 6] set idx = 6;

      create app:[906, 'APP3', 8] set idx = 7;
      create app:[906, 'APP3', 9] set idx = 8;
      create app:[906, 'APP3', 10] set idx = 9;

      create app:[902, 'APP5', 1] set idx = 10;
      create app:[902, 'APP5', 2] set idx = 11;
      create app:[902, 'APP5', 3] set idx = 12;
      |

      {:ok, _} = Surrealix.query(pid, sql_setup)

      sql = ~s|
      -- get all apps for 902 (..= means inclusive)
      select * from app:[902, NONE]..=[902];

      -- get all apps for 902 + 906
      select * from app:[902, 'APP1', NONE]..=[906, 'APP1'];

      -- get all apps for 906 (APP1)
      select * from app:[906, NONE]..=[906];
      |

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [
            %{"id" => "app:[902, 'APP1', 1]", "idx" => 1},
            %{"id" => "app:[902, 'APP1', 2]", "idx" => 2},
            %{"id" => "app:[902, 'APP1', 3]", "idx" => 3},
            %{"id" => "app:[902, 'APP5', 1]", "idx" => 10},
            %{"id" => "app:[902, 'APP5', 2]", "idx" => 11},
            %{"id" => "app:[902, 'APP5', 3]", "idx" => 12}
          ],
          ok: [
            %{"id" => "app:[902, 'APP1', 1]", "idx" => 1},
            %{"id" => "app:[902, 'APP1', 2]", "idx" => 2},
            %{"id" => "app:[902, 'APP1', 3]", "idx" => 3},
            %{"id" => "app:[902, 'APP5', 1]", "idx" => 10},
            %{"id" => "app:[902, 'APP5', 2]", "idx" => 11},
            %{"id" => "app:[902, 'APP5', 3]", "idx" => 12},
            %{"id" => "app:[906, 'APP1', 2]", "idx" => 4},
            %{"id" => "app:[906, 'APP1', 4]", "idx" => 5},
            %{"id" => "app:[906, 'APP1', 6]", "idx" => 6}
          ],
          ok: [
            %{"id" => "app:[906, 'APP1', 2]", "idx" => 4},
            %{"id" => "app:[906, 'APP1', 4]", "idx" => 5},
            %{"id" => "app:[906, 'APP1', 6]", "idx" => 6},
            %{"id" => "app:[906, 'APP3', 8]", "idx" => 7},
            %{"id" => "app:[906, 'APP3', 9]", "idx" => 8},
            %{"id" => "app:[906, 'APP3', 10]", "idx" => 9}
          ]
        ] <- parsed
      )
    end
  end
end
