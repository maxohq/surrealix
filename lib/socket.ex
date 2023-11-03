## **** GENERATED CODE! see gen/src/SocketGenerator.ts for details. ****

defmodule Surrealix.Socket do
  use WebSockex
  alias Surrealix.Config
  alias Surrealix.Telemetry
  @type base_connection_opts :: Config.socket_opts()

  require Logger

  @spec start_link(Config.socket_opts()) :: WebSockex.on_start()
  def start_link(opts \\ []) do
    opts = Keyword.merge(Config.base_conn_opts(), opts)

    hostname = Keyword.get(opts, :hostname)
    port = Keyword.get(opts, :port)

    WebSockex.start_link("ws://#{hostname}:#{port}/rpc", __MODULE__, opts)
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  def terminate(reason, state) do
    IO.puts("Socket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")
    exit(:normal)
  end

  def handle_cast(caller, _state) do
    {method, args} = caller

    payload = build_cast_payload(method, args)

    frame = {:text, payload}
    {:reply, frame, args}
  end

  def handle_frame({type, msg}, state) do
    IO.inspect({"HANDLE_FRAME", type, msg})
    # IO.inspect(state, label: "state")
    task = Keyword.get(state, :__receiver__)

    Process.send(task.pid, {:ok, Jason.decode!(msg)}, [])
    {:ok, state}
  end

  defp exec_method(pid, {method, args}, opts \\ []) do
    start_time = System.monotonic_time()
    meta = %{method: method, args: args}
    Telemetry.start(:exec_method, meta)

    task =
      Task.async(fn ->
        receive do
          {:ok, msg} ->
            if is_map(msg) and Map.has_key?(msg, "error"), do: {:error, msg}, else: {:ok, msg}

          {:error, reason} ->
            {:error, reason}

          _ ->
            {:error, "Unknown Error"}
        end
      end)

    WebSockex.cast(pid, {method, Keyword.merge([__receiver__: task], args)})

    task_timeout = Keyword.get(opts, :timeout, :infinity)
    res = Task.await(task, task_timeout)
    Telemetry.stop(:exec_method, start_time, meta)
    res
  end

  defp task_opts_default, do: [timeout: :infinity]

  defp build_cast_payload(method, args) do
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
      "id" => :rand.uniform(9999) |> to_string(),
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
    exec_method(pid, {"ping", []})
  end

  def ping(pid, task, opts \\ task_opts_default()) do
    exec_method(pid, {"ping", [__receiver__: task]}, opts)
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
    exec_method(pid, {"use", [ns: ns, db: db]})
  end

  def use(pid, ns, db, task, opts \\ task_opts_default()) do
    exec_method(pid, {"use", [ns: ns, db: db, __receiver__: task]}, opts)
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
    exec_method(pid, {"info", []})
  end

  def info(pid, task, opts \\ task_opts_default()) do
    exec_method(pid, {"info", [__receiver__: task]}, opts)
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
    exec_method(pid, {"signup", [payload: payload]})
  end

  def signup(pid, payload, task, opts \\ task_opts_default()) do
    exec_method(pid, {"signup", [payload: payload, __receiver__: task]}, opts)
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
    exec_method(pid, {"signin", [payload: payload]})
  end

  def signin(pid, payload, task, opts \\ task_opts_default()) do
    exec_method(pid, {"signin", [payload: payload, __receiver__: task]}, opts)
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
    exec_method(pid, {"authenticate", [token: token]})
  end

  def authenticate(pid, token, task, opts \\ task_opts_default()) do
    exec_method(pid, {"authenticate", [token: token, __receiver__: task]}, opts)
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
    exec_method(pid, {"invalidate", []})
  end

  def invalidate(pid, task, opts \\ task_opts_default()) do
    exec_method(pid, {"invalidate", [__receiver__: task]}, opts)
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
    exec_method(pid, {"let", [name: name, value: value]})
  end

  def let(pid, name, value, task, opts \\ task_opts_default()) do
    exec_method(pid, {"let", [name: name, value: value, __receiver__: task]}, opts)
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
    exec_method(pid, {"unset", [name: name]})
  end

  def unset(pid, name, task, opts \\ task_opts_default()) do
    exec_method(pid, {"unset", [name: name, __receiver__: task]}, opts)
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
    exec_method(pid, {"live", [table: table, diff: diff]})
  end

  def live(pid, table, diff, task, opts \\ task_opts_default()) do
    exec_method(pid, {"live", [table: table, diff: diff, __receiver__: task]}, opts)
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
    exec_method(pid, {"kill", [queryUuid: queryUuid]})
  end

  def kill(pid, queryUuid, task, opts \\ task_opts_default()) do
    exec_method(pid, {"kill", [queryUuid: queryUuid, __receiver__: task]}, opts)
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
    exec_method(pid, {"query", [sql: sql, vars: vars]})
  end

  def query(pid, sql, vars, task, opts \\ task_opts_default()) do
    exec_method(pid, {"query", [sql: sql, vars: vars, __receiver__: task]}, opts)
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
    exec_method(pid, {"select", [thing: thing]})
  end

  def select(pid, thing, task, opts \\ task_opts_default()) do
    exec_method(pid, {"select", [thing: thing, __receiver__: task]}, opts)
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
    exec_method(pid, {"create", [thing: thing, data: data]})
  end

  def create(pid, thing, data, task, opts \\ task_opts_default()) do
    exec_method(pid, {"create", [thing: thing, data: data, __receiver__: task]}, opts)
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
    exec_method(pid, {"insert", [thing: thing, data: data]})
  end

  def insert(pid, thing, data, task, opts \\ task_opts_default()) do
    exec_method(pid, {"insert", [thing: thing, data: data, __receiver__: task]}, opts)
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
    exec_method(pid, {"update", [thing: thing, data: data]})
  end

  def update(pid, thing, data, task, opts \\ task_opts_default()) do
    exec_method(pid, {"update", [thing: thing, data: data, __receiver__: task]}, opts)
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
    exec_method(pid, {"merge", [thing: thing, data: data]})
  end

  def merge(pid, thing, data, task, opts \\ task_opts_default()) do
    exec_method(pid, {"merge", [thing: thing, data: data, __receiver__: task]}, opts)
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
    exec_method(pid, {"patch", [thing: thing, patches: patches, diff: diff]})
  end

  def patch(pid, thing, patches, diff, task, opts \\ task_opts_default()) do
    exec_method(
      pid,
      {"patch", [thing: thing, patches: patches, diff: diff, __receiver__: task]},
      opts
    )
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
    exec_method(pid, {"delete", [thing: thing]})
  end

  def delete(pid, thing, task, opts \\ task_opts_default()) do
    exec_method(pid, {"delete", [thing: thing, __receiver__: task]}, opts)
  end

  ### API METHODS : FINISH ###
end
