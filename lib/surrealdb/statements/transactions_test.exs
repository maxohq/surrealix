defmodule TransactionsTest do
  use ExUnit.Case
  use MnemeDefaults
  import TestSupport

  describe "Transactions" do
    setup [:setup_surrealix]

    test "begin/ commit ", %{pid: pid} do
      sql = ~s|
      -- Start a new database transaction. Transactions are a way to ensure multiple operations
      -- either all succeed or all fail, maintaining data integrity.
      BEGIN TRANSACTION;

      -- Create a new account with the ID 'one' and set its initial balance to 135,605.16
      CREATE account:one SET balance = 135605.16;

      -- Create another new account with the ID 'two' and set its initial balance to 91,031.31
      CREATE account:two SET balance = 91031.31;

      -- Update the balance of account 'one' by adding 300.00 to the current balance.
      -- This could represent a deposit or other form of credit on the balance property.
      UPDATE account:one SET balance += 300.00;

      -- Update the balance of account 'two' by subtracting 300.00 from the current balance.
      -- This could represent a withdrawal or other form of debit on the balance property.
      UPDATE account:two SET balance -= 300.00;

      -- Finalize the transaction. This will apply the changes to the database. If there was an error
      -- during any of the previous steps within the transaction, all changes would be rolled back and
      -- the database would remain in its initial state.
      COMMIT TRANSACTION;
      |

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: [%{"balance" => 135_605.16, "id" => "account:one"}],
          ok: [%{"balance" => 91031.31, "id" => "account:two"}],
          ok: [%{"balance" => 135_905.16, "id" => "account:one"}],
          ok: [%{"balance" => 90731.31, "id" => "account:two"}]
        ] <- parsed
      )
    end

    test "begin / cancel", %{pid: pid} do
      sql = ~s|
      BEGIN TRANSACTION;
      -- Setup accounts
      CREATE account:one SET balance = 135605.16;
      CREATE account:two SET balance = 91031.31;
      -- Move money
      UPDATE account:one SET balance += 300.00;
      UPDATE account:two SET balance -= 300.00;
      -- Rollback all changes
      CANCEL TRANSACTION;

      select * from account;
      |

      parsed = Surrealix.query(pid, sql) |> extract_res_list()

      auto_assert(
        [
          ok: "The query was not executed due to a cancelled transaction",
          ok: "The query was not executed due to a cancelled transaction",
          ok: "The query was not executed due to a cancelled transaction",
          ok: "The query was not executed due to a cancelled transaction",
          ok: []
        ] <- parsed
      )
    end
  end
end
