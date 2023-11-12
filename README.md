# Surrealix

[![CI](https://github.com/maxohq/surrealix/actions/workflows/ci.yml/badge.svg?style=flat)](https://github.com/maxohq/surrealix/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/surrealix.svg?style=flat)](https://hex.pm/packages/surrealix)
[![Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg?style=flat)](https://hexdocs.pm/surrealix)
[![Total Download](https://img.shields.io/hexpm/dt/surrealix.svg?style=flat)](https://hex.pm/packages/surrealix)
[![License](https://img.shields.io/hexpm/l/surrealix.svg?style=flat)](https://github.com/maxohq/surrealix/blob/main/LICENCE)

---

Lightweight, correct and up-to-date Elixir SDK for [SurrealDB](https://surrealdb.com/docs/integration/sdks).

## Why use Surrealix?
  - currently the most full-featured SurrealDB SKD for Elixir

  - API
    - up-to-date on the Websocket API for SurrealDB (https://github.com/maxohq/surrealix/blob/main/gen/src/api.ts) - via code generation
    - minimal abstraction over [WebSocket (text protocol)](https://surrealdb.com/docs/integration/websocket/text) for SurrealDB
    - Elixir documentation shows raw examples from the SurrealDB docs, so that it's very clear what happens behind the covers. You can keep referring the official docs!

  - Live Queries
    - the only Elixir SDK to provide first-class support for live-query callbacks

  - Reconnection
    - working re-connection handling that includes:
      - re-executing the 'on_auth' callback
      - re-establishing subscriptions for active live queries

  - Logging
    - verbose logging via:
      - `config :logger, :console, level: :debug`
      - `Surrealix.start_link(debug: [:trace])` (from WebSockex)

  - Telemetry
    - `:telemetry` events for request handling
      - `Surrealix.Telemetry.Logger.setup()` for STDOUT events

  - Testing
    - extensive, readable and maintainable E2E test suite
    - uses [mneme](https://github.com/zachallaun/mneme) to update inline snapshots without any effort
    - tests run on isolated databases, that are removed after each test completion. Your local data stays safe!
    - uses [maxo_test_iex](https://github.com/maxohq/maxo_test_iex) for rapid feedbaack during local development



## Usage

```elixir
# {:ok, pid} = Surrealix.start_link(debug: [:trace]) ## for debugging!
{:ok, pid} = Surrealix.start_link()
Surrealix.signin(pid, %{user: "root", pass: "root"})
Surrealix.use(pid, "test", "test")
Surrealix.query(pid, "SELECT * FROM person;")
Surrealix.query(pid, "SELECT * FROM type::table($table);", %{table: "person"})
```

```elixir
## Example with live query callbacks
Surrealix.live_query(pid, "LIVE SELECT * FROM user;", fn data, query_id ->
  IO.inspect({data, query_id}, label: "callback")
end)

## Example with live query with DIFF
Surrealix.live_query(pid, "LIVE SELECT DIFF FROM user;", fn data, query_id ->
  IO.inspect({data, query_id}, label: "callback")
end)


# inspect currently registered live queries
Surrealix.all_live_queries(pid)
```

## Handling reconnection

To properly deal with connection drops, provide an `on_auth`-callback when starting a Surrealix Socket. `on_auth` callbacks should include logic to authenticate the connection and select a namespace / database.

This callback is called in a non-blocking fashion, so it is important to wait until the `on_auth`-callback is finished. This is done via `Surrealix.wait_until_auth_ready(pid)` function, that checks auth status via busy-waiting.

Live queries that were setup via `Surrealix.live_query(pid, sql, callback)` function are registed on SocketState and will be re-established after a successful reconnection.

```elixir
{:ok, pid} =
    Surrealix.start(
      on_auth: fn pid, _state ->
        IO.puts("PID: #{inspect(pid)}")
        Surrealix.signin(pid, %{user: "root", pass: "root"}) |> IO.inspect(label: :signin)
        Surrealix.use(pid, "test", "test") |> IO.inspect(label: :use)
      end
    )

# blocks until the `on_auth` callback is executed
Surrealix.wait_until_auth_ready(pid)

# now we can execute queries, that require auth
Surrealix.live_query(pid, "LIVE SELECT * FROM user;", fn data, query_id ->
  IO.inspect({data, query_id}, label: "callback")
end)

Surrealix.live_query(pid, "LIVE SELECT * FROM person;", fn data, query_id ->
  IO.inspect({data, query_id}, label: "callback")
end)
```

## Telemetry
Currently library publishes only 3 events:
```elixir
events = [
  [:surrealix, :exec_method, :start],
  [:surrealix, :exec_method, :stop],
  [:surrealix, :exec_method, :exception]
]
```

In the `meta` there is further information about the method name and the arguments, that were sent to SurrealDB server.

As example we provide a `Surrealix.Telemetry.Logger`, that logs those events to the console.

```elixir
## Configure basic logger telemetry
Surrealix.Telemetry.Logger.setup()
```

## Configuration

```elixir
## in config.exs / runtime.exs file
config :surrealix, backoff_max: 2000
config :surrealix, backoff_step: 50
config :surrealix, timeout: :infinity # default 5000
config :surrealix, :conn,
  hostname: "0.0.0.0",
  port: 8000
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `surrealix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:surrealix, "~> 0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/surrealix>.

## Aknowledgements

Code foundation was taken from https://github.com/joojscript/surrealdb_ex. Since this package has not received any commits in the last 7 months (2023-10-31) and the issues are left uncommented, I have assumed that the maintainer is not interested in any contributions.

## Ref

- [Websockex callbacks (Elixir)](https://github.com/Azolo/websockex/blob/master/lib/websockex.ex)
- [Websocket Text Protocol](https://surrealdb.com/docs/integration/websocket/text)
- [JS SDK for websockets](https://github.com/surrealdb/surrealdb.js/blob/main/src/strategies/websocket.ts)
- [Source code for the Websocket Text Protocol docs](https://github.com/surrealdb/www.surrealdb.com/blob/main/app/templates/docs/integration/websocket/text.hbs)
- [SurrealDB SQL statements](https://surrealdb.com/docs/surrealql/statements)
- [SurrealDB functions](https://surrealdb.com/docs/surrealql/functions)


## Support

<p>
  <a href="https://quantor.consulting/?utm_source=github&utm_campaign=surrealix">
    <img src="https://raw.githubusercontent.com/maxohq/sponsors/main/assets/quantor_consulting_logo.svg"
      alt="Sponsored by Quantor Consulting" width="210">
  </a>
</p>

## License

The lib is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
