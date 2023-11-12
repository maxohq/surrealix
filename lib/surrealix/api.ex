## **** GENERATED CODE! see gen/src/ApiGenerator.ts for details. ****

defmodule Surrealix.Api do
  @moduledoc """
  Thin layer over the Websockets API for SurrealDB that is 100% generated from a data-structure.
  """

  alias Surrealix.Config
  alias Surrealix.Socket
  alias Surrealix.SocketState
  alias Surrealix.Util

  defp exec_method(pid, {method, args, task}, opts \\ []) do
    Socket.exec_method(pid, {method, args, task}, opts)
  end

  @doc """
  Show all currently registered live queries (SQL)
  """
  def all_live_queries(pid) do
    :sys.get_state(pid) |> SocketState.all_live_queries()
  end

  @doc """
  Convenience method that combines sending a (live-)query and registering a callback.

  Params:
      sql: string
      vars: map with variables to interpolate into SQL
      callback: fn (data, live_query_id)
  """
  @spec live_query(pid(), String.t(), map(), (any, String.t() -> any)) :: :ok
  def live_query(pid, sql, vars \\ %{}, callback) do
    with {:sql_live_check, true} <- {:sql_live_check, Util.is_live_query_stmt(sql)},
         {:ok, res} <- query(pid, sql, vars),
         %{"result" => [%{"result" => lq_id}]} <- res do
      :ok = WebSockex.cast(pid, {:register_live_query, sql, lq_id, callback})
      {:ok, res}
    else
      {:sql_live_check, false} -> {:error, "Not a live query: `#{sql}`!"}
    end
  end

  def build_cast_payload(method, args, id) do
    params =
      case method do
        "ping" -> []
        "use" -> [args[:ns], args[:db]]
        "info" -> []
        "signup" -> [args[:payload]]
        "signin" -> [args[:payload]]
        "authenticate" -> [args[:token]]
        "invalidate" -> []
        "let" -> [args[:name], args[:value]]
        "unset" -> [args[:name]]
        "live" -> [args[:table], args[:diff]]
        "kill" -> [args[:queryUuid]]
        "query" -> [args[:sql], args[:vars]]
        "select" -> [args[:thing]]
        "create" -> [args[:thing], args[:data]]
        "insert" -> [args[:thing], args[:data]]
        "update" -> [args[:thing], args[:data]]
        "merge" -> [args[:thing], args[:data]]
        "patch" -> [args[:thing], args[:patches], args[:diff]]
        "delete" -> [args[:thing]]
      end

    %{
      "id" => id,
      "method" => method,
      "params" => params
    }
    |> Jason.encode!()
  end

  ### API METHODS : START ###
  @doc """
  ping
    This method pings the SurrealDB instance

    Example request:
      {
        "id": 1,
        "method": "ping"
      }

    Example response:
      {
        "id": 1,
        "result": null
      }
  """
  def ping(pid) do
    exec_method(pid, {"ping", [], nil})
  end

  def ping(pid, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"ping", [], task}, opts)
  end

  @doc """
  use [ ns, db ]
    Specifies the namespace and database for the current connection

    Example request:
      {
        "id": 1,
        "method": "use",
        "params": [
          "surrealdb",
          "docs"
        ]
      }

    Example response:
      {
        "id": 1,
        "result": null
      }
  """
  def use(pid, ns, db) do
    exec_method(pid, {"use", [ns: ns, db: db], nil})
  end

  def use(pid, ns, db, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"use", [ns: ns, db: db], task}, opts)
  end

  @doc """
  info
    This method returns the record of an authenticated scope user.

    Example request:
      {
        "id": 1,
        "method": "info"
      }

    Example response:
      {
        "id": 1,
        "result": {
          "id": "user:john",
          "name": "John Doe"
        }
      }
  """
  def info(pid) do
    exec_method(pid, {"info", [], nil})
  end

  def info(pid, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"info", [], task}, opts)
  end

  @doc """
  signup [ NS, DB, SC, ... ]
    This method allows you to signup a user against a scope's SIGNUP method

    Example request:
      {
        "id": 1,
        "method": "signup",
        "params": [
          {
            "NS": "surrealdb",
            "DB": "docs",
            "SC": "commenter",
            "username": "johndoe",
            "password": "SuperStrongPassword!"
          }
        ]
      }

    Example response:
      {
        "id": 1,
        "result": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTdXJyZWFsREIiLCJpYXQiOjE1MTYyMzkwMjIsIm5iZiI6MTUxNjIzOTAyMiwiZXhwIjoxODM2NDM5MDIyLCJOUyI6InRlc3QiLCJEQiI6InRlc3QiLCJTQyI6InVzZXIiLCJJRCI6InVzZXI6dG9iaWUifQ.N22Gp9ze0rdR06McGj1G-h2vu6a6n9IVqUbMFJlOxxA"
      }
  """
  def signup(pid, payload) do
    exec_method(pid, {"signup", [payload: payload], nil})
  end

  def signup(pid, payload, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"signup", [payload: payload], task}, opts)
  end

  @doc """
  signin [ NS, DB, SC, ... ]
    This method allows you to signin a root, NS, DB or SC user against SurrealDB
    As Root

    Example request:
      {
        "id": 1,
        "method": "signin",
        "params": [
          {
            "user": "tobie",
            "pass": "3xtr3m3ly-s3cur3-p@ssw0rd"
          }
        ]
      }

    Example response:
      {
        "id": 1,
        "result": null
      }
    Signin as scope

    Example request:
      {
        "id": 1,
        "method": "signin",
        "params": [
          {
            "NS": "surrealdb",
            "DB": "docs",
            "SC": "commenter",
            "username": "johndoe",
            "password": "SuperStrongPassword!"
          }
        ]
      }

    Example response:
      {
        "id": 1,
        "result": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTdXJyZWFsREIiLCJpYXQiOjE1MTYyMzkwMjIsIm5iZiI6MTUxNjIzOTAyMiwiZXhwIjoxODM2NDM5MDIyLCJOUyI6InRlc3QiLCJEQiI6InRlc3QiLCJTQyI6InVzZXIiLCJJRCI6InVzZXI6dG9iaWUifQ.N22Gp9ze0rdR06McGj1G-h2vu6a6n9IVqUbMFJlOxxA"
      }
  """
  def signin(pid, payload) do
    exec_method(pid, {"signin", [payload: payload], nil})
  end

  def signin(pid, payload, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"signin", [payload: payload], task}, opts)
  end

  @doc """
  authenticate [ token ]
    This method allows you to authenticate a user against SurrealDB with a token

    Example request:
      {
        "id": 1,
        "method": "authenticate",
        "params": [
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTdXJyZWFsREIiLCJpYXQiOjE1MTYyMzkwMjIsIm5iZiI6MTUxNjIzOTAyMiwiZXhwIjoxODM2NDM5MDIyLCJOUyI6InRlc3QiLCJEQiI6InRlc3QiLCJTQyI6InVzZXIiLCJJRCI6InVzZXI6dG9iaWUifQ.N22Gp9ze0rdR06McGj1G-h2vu6a6n9IVqUbMFJlOxxA"
        ]
      }

    Example response:
      {
        "id": 1,
        "result": null
      }
  """
  def authenticate(pid, token) do
    exec_method(pid, {"authenticate", [token: token], nil})
  end

  def authenticate(pid, token, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"authenticate", [token: token], task}, opts)
  end

  @doc """
  invalidate
    This method will invalidate the user's session for the current connection

    Example request:
      {
        "id": 1,
        "method": "invalidate"
      }

    Example response:
      {
        "id": 1,
        "result": null
      }
  """
  def invalidate(pid) do
    exec_method(pid, {"invalidate", [], nil})
  end

  def invalidate(pid, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"invalidate", [], task}, opts)
  end

  @doc """
  let [ name, value ]
    This method stores a variable on the current connection

    Example request:
      {
        "id": 1,
        "method": "let",
        "params": [
          "website",
          "https://surrealdb.com/"
        ]
      }

    Example response:
      {
        "id": 1,
        "result": null
      }
  """
  def let(pid, name, value) do
    exec_method(pid, {"let", [name: name, value: value], nil})
  end

  def let(pid, name, value, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"let", [name: name, value: value], task}, opts)
  end

  @doc """
  unset [ name ]
    This method removes a variable from the current connection

    Example request:
      {
        "id": 1,
        "method": "unset",
        "params": [
          "website"
        ]
      }

    Example response:
      {
        "id": 1,
        "result": null
      }
  """
  def unset(pid, name) do
    exec_method(pid, {"unset", [name: name], nil})
  end

  def unset(pid, name, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"unset", [name: name], task}, opts)
  end

  @doc """
  live [ table ]
    This methods initiates a live query for a specified table name
    NOTE: For more advanced live queries where filters are needed, use the Query method to initiate a custom live query.

    Example request:
      {
        "id": 1,
        "method": "live",
        "params": [
          "person"
        ]
      }

    Example response:
      {
        "id": 1,
        "result": "0189d6e3-8eac-703a-9a48-d9faa78b44b9"
      }
    Live notification

    Example request:
      {}

    Example response:
      {
        "result": {
          "action": "CREATE",
          "id": "0189d6e3-8eac-703a-9a48-d9faa78b44b9",
          "result": {
            "id": "person:8s0j0bbm3ngrd5c9bx53",
            "name": "John"
          }
        }
      }
  """
  def live(pid, table, diff \\ false) do
    exec_method(pid, {"live", [table: table, diff: diff], nil})
  end

  def live(pid, table, diff, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"live", [table: table, diff: diff], task}, opts)
  end

  @doc """
  kill [ queryUuid ]
    This methods kills an active live query

    Example request:
      {
        "id": 1,
        "method": "kill",
        "params": [
          "0189d6e3-8eac-703a-9a48-d9faa78b44b9"
        ]
      }

    Example response:
      {
        "id": 1,
        "result": null
      }
  """
  def kill(pid, queryUuid) do
    exec_method(pid, {"kill", [queryUuid: queryUuid], nil})
  end

  def kill(pid, queryUuid, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"kill", [queryUuid: queryUuid], task}, opts)
  end

  @doc """
  query [ sql, vars ]
    This method executes a custom query against SurrealDB

    Example request:
      {
        "id": 1,
        "method": "query",
        "params": [
          "CREATE person SET name = 'John'; SELECT * FROM type::table($tb);",
          {
            "tb": "person"
          }
        ]
      }

    Example response:
      {
        "id": 1,
        "result": [
          {
            "status": "OK",
            "time": "152.5µs",
            "result": [
              {
                "id": "person:8s0j0bbm3ngrd5c9bx53",
                "name": "John"
              }
            ]
          },
          {
            "status": "OK",
            "time": "32.375µs",
            "result": [
              {
                "id": "person:8s0j0bbm3ngrd5c9bx53",
                "name": "John"
              }
            ]
          }
        ]
      }
  """
  def query(pid, sql, vars \\ %{}) do
    exec_method(pid, {"query", [sql: sql, vars: vars], nil})
  end

  def query(pid, sql, vars, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"query", [sql: sql, vars: vars], task}, opts)
  end

  @doc """
  select [ thing ]
    This method selects either all records in a table or a single record

    Example request:
      {
        "id": 1,
        "method": "select",
        "params": [
          "person"
        ]
      }

    Example response:
      {
        "id": 1,
        "result": [
          {
            "id": "person:8s0j0bbm3ngrd5c9bx53",
            "name": "John"
          }
        ]
      }
  """
  def select(pid, thing) do
    exec_method(pid, {"select", [thing: thing], nil})
  end

  def select(pid, thing, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"select", [thing: thing], task}, opts)
  end

  @doc """
  create [ thing, data ]
    This method creates a record either with a random or specified ID

    Example request:
      {
        "id": 1,
        "method": "create",
        "params": [
          "person",
          {
            "name": "Mary Doe"
          }
        ]
      }

    Example response:
      {
        "id": 1,
        "result": [
          {
            "id": "person:s5fa6qp4p8ey9k5j0m9z",
            "name": "Mary Doe"
          }
        ]
      }
  """
  def create(pid, thing, data \\ %{}) do
    exec_method(pid, {"create", [thing: thing, data: data], nil})
  end

  def create(pid, thing, data, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"create", [thing: thing, data: data], task}, opts)
  end

  @doc """
  insert [ thing, data ]
    This method creates a record either with a random or specified ID
    Single insert

    Example request:
      {
        "id": 1,
        "method": "insert",
        "params": [
          "person",
          {
            "name": "Mary Doe"
          }
        ]
      }

    Example response:
      {
        "id": 1,
        "result": [
          {
            "id": "person:s5fa6qp4p8ey9k5j0m9z",
            "name": "Mary Doe"
          }
        ]
      }
    Bulk insert

    Example request:
      {
        "id": 1,
        "method": "insert",
        "params": [
          "person",
          [
            {
              "name": "Mary Doe"
            },
            {
              "name": "John Doe"
            }
          ]
        ]
      }

    Example response:
      {
        "id": 1,
        "result": [
          {
            "id": "person:s5fa6qp4p8ey9k5j0m9z",
            "name": "Mary Doe"
          },
          {
            "id": "person:xtbbojcm82a97vus9x0j",
            "name": "John Doe"
          }
        ]
      }
  """
  def insert(pid, thing, data \\ %{}) do
    exec_method(pid, {"insert", [thing: thing, data: data], nil})
  end

  def insert(pid, thing, data, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"insert", [thing: thing, data: data], task}, opts)
  end

  @doc """
  update [ thing, data ]
    This method replaces either all records in a table or a single record with specified data
    NOTE: This function replaces the current document / record data with the specified data. If no replacement data is passed it will simply trigger an update.

    Example request:
      {
        "id": 1,
        "method": "update",
        "params": [
          "person:8s0j0bbm3ngrd5c9bx53",
          {
            "name": "John Doe"
          }
        ]
      }

    Example response:
      {
        "id": 1,
        "result": {
          "id": "person:8s0j0bbm3ngrd5c9bx53",
          "name": "John Doe"
        }
      }
  """
  def update(pid, thing, data \\ %{}) do
    exec_method(pid, {"update", [thing: thing, data: data], nil})
  end

  def update(pid, thing, data, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"update", [thing: thing, data: data], task}, opts)
  end

  @doc """
  merge [ thing, data ]
    This method merges specified data into either all records in a table or a single record
    NOTE: This function merges the current document / record data with the specified data. If no merge data is passed it will simply trigger an update.

    Example request:
      {
        "id": 1,
        "method": "merge",
        "params": [
          "person",
          {
            "active": true
          }
        ]
      }

    Example response:
      {
        "id": 1,
        "result": [
          {
            "active": true,
            "id": "person:8s0j0bbm3ngrd5c9bx53",
            "name": "John Doe"
          },
          {
            "active": true,
            "id": "person:s5fa6qp4p8ey9k5j0m9z",
            "name": "Mary Doe"
          }
        ]
      }
  """
  def merge(pid, thing, data \\ %{}) do
    exec_method(pid, {"merge", [thing: thing, data: data], nil})
  end

  def merge(pid, thing, data, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"merge", [thing: thing, data: data], task}, opts)
  end

  @doc """
  patch [ thing, patches, diff ]
    This method patches either all records in a table or a single record with specified patches
    NOTE: This function patches the current document / record data with the specified JSON Patch data.

    Example request:
      {
        "id": 1,
        "method": "patch",
        "params": [
          "person",
          [
            {
              "op": "replace",
              "path": "/last_updated",
              "value": "2023-06-16T08:34:25Z"
            }
          ]
        ]
      }

    Example response:
      {
        "id": 1,
        "result": [
          [
            {
              "op": "add",
              "path": "/last_updated",
              "value": "2023-06-16T08:34:25Z"
            }
          ],
          [
            {
              "op": "add",
              "path": "/last_updated",
              "value": "2023-06-16T08:34:25Z"
            }
          ]
        ]
      }
  """
  def patch(pid, thing, patches, diff \\ false) do
    exec_method(pid, {"patch", [thing: thing, patches: patches, diff: diff], nil})
  end

  def patch(pid, thing, patches, diff, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"patch", [thing: thing, patches: patches, diff: diff], task}, opts)
  end

  @doc """
  delete [ thing ]
    This method deletes either all records in a table or a single record
    NOTE: Notice how the deleted record is being returned here

    Example request:
      {
        "id": 1,
        "method": "delete",
        "params": [
          "person:8s0j0bbm3ngrd5c9bx53"
        ]
      }

    Example response:
      {
        "id": 1,
        "result": {
          "active": true,
          "id": "person:8s0j0bbm3ngrd5c9bx53",
          "last_updated": "2023-06-16T08:34:25Z",
          "name": "John Doe"
        }
      }
  """
  def delete(pid, thing) do
    exec_method(pid, {"delete", [thing: thing], nil})
  end

  def delete(pid, thing, task, opts \\ Config.task_opts_default()) do
    exec_method(pid, {"delete", [thing: thing], task}, opts)
  end

  ### API METHODS : FINISH ###
end
