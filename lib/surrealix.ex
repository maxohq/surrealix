## **** GENERATED CODE! see gen/src/MainGenerator.ts for details. ****

defmodule Surrealix do
  @moduledoc """
  Main entry module for Surrealix
  """
  alias Surrealix.Api, as: Api
  alias Surrealix.Socket, as: Socket

  defdelegate start(opts \\ []), to: Socket
  defdelegate start_link(opts \\ []), to: Socket
  defdelegate stop(pid), to: Socket

  defdelegate all_live_queries(pid), to: Socket
  defdelegate reset_live_queries(pid), to: Socket
  defdelegate set_auth_ready(pid, value), to: Socket
  defdelegate wait_until_auth_ready(pid), to: Socket

  @doc """
  Convenience method, that combines sending an query (live_query) and registering a callback

  Params:
    sql: string
    vars: map with variables to interpolate into SQL
    callback: fn (event, data, config)
  """
  defdelegate live_query(pid, sql, vars \\ %{}, callback), to: Api

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
  defdelegate ping(pid), to: Api

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
  defdelegate use(pid, ns, db), to: Api
  defdelegate use(pid, ns, db, task), to: Api
  defdelegate use(pid, ns, db, task, opts), to: Api

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
  defdelegate info(pid), to: Api

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
  defdelegate signup(pid, payload), to: Api
  defdelegate signup(pid, payload, task), to: Api
  defdelegate signup(pid, payload, task, opts), to: Api

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
  defdelegate signin(pid, payload), to: Api
  defdelegate signin(pid, payload, task), to: Api
  defdelegate signin(pid, payload, task, opts), to: Api

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
  defdelegate authenticate(pid, token), to: Api
  defdelegate authenticate(pid, token, task), to: Api
  defdelegate authenticate(pid, token, task, opts), to: Api

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
  defdelegate invalidate(pid), to: Api

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
  defdelegate let(pid, name, value), to: Api
  defdelegate let(pid, name, value, task), to: Api
  defdelegate let(pid, name, value, task, opts), to: Api

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
  defdelegate unset(pid, name), to: Api
  defdelegate unset(pid, name, task), to: Api
  defdelegate unset(pid, name, task, opts), to: Api

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
  defdelegate live(pid, table, diff \\ false), to: Api
  defdelegate live(pid, table, diff, task), to: Api
  defdelegate live(pid, table, diff, task, opts), to: Api

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
  defdelegate kill(pid, queryUuid), to: Api
  defdelegate kill(pid, queryUuid, task), to: Api
  defdelegate kill(pid, queryUuid, task, opts), to: Api

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
  defdelegate query(pid, sql, vars \\ %{}), to: Api
  defdelegate query(pid, sql, vars, task), to: Api
  defdelegate query(pid, sql, vars, task, opts), to: Api

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
  defdelegate select(pid, thing), to: Api
  defdelegate select(pid, thing, task), to: Api
  defdelegate select(pid, thing, task, opts), to: Api

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
  defdelegate create(pid, thing, data \\ %{}), to: Api
  defdelegate create(pid, thing, data, task), to: Api
  defdelegate create(pid, thing, data, task, opts), to: Api

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
  defdelegate insert(pid, thing, data \\ %{}), to: Api
  defdelegate insert(pid, thing, data, task), to: Api
  defdelegate insert(pid, thing, data, task, opts), to: Api

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
  defdelegate update(pid, thing, data \\ %{}), to: Api
  defdelegate update(pid, thing, data, task), to: Api
  defdelegate update(pid, thing, data, task, opts), to: Api

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
  defdelegate merge(pid, thing, data \\ %{}), to: Api
  defdelegate merge(pid, thing, data, task), to: Api
  defdelegate merge(pid, thing, data, task, opts), to: Api

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
  defdelegate patch(pid, thing, patches, diff \\ false), to: Api
  defdelegate patch(pid, thing, patches, diff, task), to: Api
  defdelegate patch(pid, thing, patches, diff, task, opts), to: Api

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
  defdelegate delete(pid, thing), to: Api
  defdelegate delete(pid, thing, task), to: Api
  defdelegate delete(pid, thing, task, opts), to: Api
end
