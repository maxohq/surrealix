# Surrealix

[![CI](https://github.com/maxohq/surrealix/actions/workflows/ci.yml/badge.svg?style=flat)](https://github.com/maxohq/surrealix/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/surrealix.svg?style=flat)](https://hex.pm/packages/surrealix)
[![Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg?style=flat)](https://hexdocs.pm/surrealix)
[![Total Download](https://img.shields.io/hexpm/dt/surrealix.svg?style=flat)](https://hex.pm/packages/surrealix)
[![License](https://img.shields.io/hexpm/l/surrealix.svg?style=flat)](https://github.com/maxohq/surrealix/blob/main/LICENCE)

---

Lightweight, correct and up-to-date Elixir SDK for [SurrealDB](https://surrealdb.com/docs/integration/sdks).


## Why use Surrealix?
  - up-to-date on the Websocket API for SurrealDB (https://github.com/maxohq/surrealix/blob/main/gen/src/api.ts) - via code generation
  - minimal abstraction over [WebSocket (text protocol)](https://surrealdb.com/docs/integration/websocket/text) for SurrealDB
  - Elixir documentation shows raw examples from the SurrealDB docs, so that it's very clear what happens behind the covers. You can keep referring the official docs!
  - first-class support for live-query callbacks (currently the ONLY Elixir SDK)
  - `:telemetry` events for request handling
  - extensive and very maintainble (thanks to [mneme](https://github.com/zachallaun/mneme)) E2E tests against SurrealDB server (https://github.com/maxohq/surrealix/tree/main/lib/surrealdb)


## Usage

```elixir
# {:ok, pid} = Surrealix.start_link(namespace: "test", database: "test", debug: [:trace]) ## for debugging!
{:ok, pid} = Surrealix.start_link(namespace: "test", database: "test")
Surrealix.signin(pid, %{user: "root", pass: "root"})
Surrealix.use(pid, "test", "test")
Surrealix.query(pid, "SELECT * FROM person;")
Surrealix.query(pid, "SELECT * FROM type::table($table);", %{table: "person"})
```

```elixir
## Example with live query callbacks
Surrealix.live_query(pid, "LIVE SELECT * FROM user;", fn event, data, config ->
  IO.inspect({event, data, config}, label: "callback")
end)

# inspect currently registered live queries
Surrealix.all_live_queries(pid)
```


## Configuration

```elixir
## in config.exs / runtime.exs file
# default 5000
config :surrealix, timeout: :infinity
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

## Todo

- [x] handle live query updates properly
- [x] debug modus with verbose logging
- [x] integration tests
- [ ] handle disconnects gracefully
- [ ] benchmarks


## Support

<p>
  <a href="https://quantor.consulting/?utm_source=github&utm_campaign=surrealix">
    <img src="https://raw.githubusercontent.com/maxohq/sponsors/main/assets/quantor_consulting_logo.svg"
      alt="Sponsored by Quantor Consulting" width="210">
  </a>
</p>

## License

The lib is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
