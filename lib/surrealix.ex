## **** GENERATED CODE! see gen/src/TopGenerator.ts for details. ****

defmodule Surrealix do
  alias Surrealix.Socket, as: Socket

  defdelegate start_link(), to: Socket
  defdelegate start_link(opts), to: Socket

  defdelegate stop(pid), to: Socket

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
  defdelegate use(pid, ns, db), to: Socket
  defdelegate use(pid, ns, db, task), to: Socket
  defdelegate use(pid, ns, db, task, opts), to: Socket

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
  defdelegate info(pid), to: Socket

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
  defdelegate signup(pid, payload), to: Socket
  defdelegate signup(pid, payload, task), to: Socket
  defdelegate signup(pid, payload, task, opts), to: Socket

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
  defdelegate signin(pid, payload), to: Socket
  defdelegate signin(pid, payload, task), to: Socket
  defdelegate signin(pid, payload, task, opts), to: Socket

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
  defdelegate authenticate(pid, token), to: Socket
  defdelegate authenticate(pid, token, task), to: Socket
  defdelegate authenticate(pid, token, task, opts), to: Socket

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
  defdelegate invalidate(pid), to: Socket

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
  defdelegate let(pid, name, value), to: Socket
  defdelegate let(pid, name, value, task), to: Socket
  defdelegate let(pid, name, value, task, opts), to: Socket

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
  defdelegate unset(pid, name), to: Socket
  defdelegate unset(pid, name, task), to: Socket
  defdelegate unset(pid, name, task, opts), to: Socket

  @doc """
  live [ table ]
    This methods initiates a live query for a specified table name

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
  defdelegate live(pid, table, diff \\ false), to: Socket
  defdelegate live(pid, table, diff, task), to: Socket
  defdelegate live(pid, table, diff, task, opts), to: Socket

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
  defdelegate kill(pid, queryUuid), to: Socket
  defdelegate kill(pid, queryUuid, task), to: Socket
  defdelegate kill(pid, queryUuid, task, opts), to: Socket

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
  defdelegate query(pid, sql, vars \\ %{}), to: Socket
  defdelegate query(pid, sql, vars, task), to: Socket
  defdelegate query(pid, sql, vars, task, opts), to: Socket

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
  defdelegate select(pid, thing), to: Socket
  defdelegate select(pid, thing, task), to: Socket
  defdelegate select(pid, thing, task, opts), to: Socket

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
  defdelegate create(pid, thing, data \\ %{}), to: Socket
  defdelegate create(pid, thing, data, task), to: Socket
  defdelegate create(pid, thing, data, task, opts), to: Socket

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
  defdelegate insert(pid, thing, data \\ %{}), to: Socket
  defdelegate insert(pid, thing, data, task), to: Socket
  defdelegate insert(pid, thing, data, task, opts), to: Socket

  @doc """
  update [ thing, data ]
    This method replaces either all records in a table or a single record with specified data

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
  defdelegate update(pid, thing, data \\ %{}), to: Socket
  defdelegate update(pid, thing, data, task), to: Socket
  defdelegate update(pid, thing, data, task, opts), to: Socket

  @doc """
  merge [ thing, data ]
    This method merges specified data into either all records in a table or a single record

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
  defdelegate merge(pid, thing, data \\ %{}), to: Socket
  defdelegate merge(pid, thing, data, task), to: Socket
  defdelegate merge(pid, thing, data, task, opts), to: Socket

  @doc """
  patch [ thing, patches, diff ]
    This method patches either all records in a table or a single record with specified patches

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
  defdelegate patch(pid, thing, patches, diff \\ false), to: Socket
  defdelegate patch(pid, thing, patches, diff, task), to: Socket
  defdelegate patch(pid, thing, patches, diff, task, opts), to: Socket

  @doc """
  delete [ thing ]
    This method deletes either all records in a table or a single record

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
  defdelegate delete(pid, thing), to: Socket
  defdelegate delete(pid, thing, task), to: Socket
  defdelegate delete(pid, thing, task, opts), to: Socket
end
