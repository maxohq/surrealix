# Surrealix

Lightweight, correct and up-to-date Elixir SDK for [SurrealDB](https://surrealdb.com/docs/integration/sdks).

The API is 100% code-generated (https://github.com/maxohq/surrealix/blob/main/gen/src/api.ts) and implements the Websocket protocol as documented here - [WebSocket (text protocol)](https://surrealdb.com/docs/integration/websocket/text).

Elixir documentation shows raw examples from the SurrealDB docs, so that it's very clear what happens behind the covers. There are no futher abstractions, so you can keep referring the official docs while you develop your application.

## Usage

```elixir
{:ok, pid} = Surrealix.start_link(namespace: "test", database: "test", debug: [:trace])
Surrealix.signin(pid, %{user: "root", pass: "root"})
Surrealix.use(pid, "test", "test")

Surrealix.query(pid, "SELECT * FROM type::table($table);", %{table: "person"})
Surrealix.live(pid, "person", true)

## for more complex LIVE queries
Surrealix.query(pid, "LIVE SELECT * FROM person;")



## start dispatch registry

Surrealix.HandlerTable.start_link([])
Surrealix.Dispatch.attach("first", [:live_query], fn (event, data, config)-> IO.inspect({:res, event, data}) end)
Surrealix.Dispatch.remove("first")
## try running following query in the SurrealDB shell: `create person:1 set name = "John"`
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `surrealix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:surrealix, "~> 0.1.0"}
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

- [ ] handle disconnects gracefully
- [ ] handle live query updates properly
- [ ] debug modus with verbose logging
- [ ] integration tests
- [ ] benchmarks
