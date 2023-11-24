## v0.1.7 (2023-11-24)

- make JSON package configurable
    - `config :surrealix, :json, Jason`

## v0.1.6 (2023-11-24)

- simplify the API by removing the optional task as parameter
- this enables passing task options as arguments
- code becomes much clearer

## v0.1.5 (2023-11-12)

- graceful re-connection handing
- ability to register on_auth callbacks (run connection / re-connection)
- ability to re-establish live queries subscriptions on re-connections
- ability to configure max backoff / step duration for connection retries

## v0.1.4 (2023-11-11)

- much simpler handling for live query callbacks (https://github.com/maxohq/surrealix/commit/c87fe9b3853d090cb622a2478595b99a213d7fa9)

## v0.1.3 (2023-11-10)

- allow configuration the timeout for WS response
- remove unused connection params like (user/pass/ns/db), this information has to be provided after establishing the connection
- some minor cleanups


## v0.1.2 (2023-11-10)

- allow to register callbacks for live queries
- E2E tests
- pave the way to handle disconnects gracefully, by re-establishing active live queries on reconnect

## v0.1.1 (2023-11-03)

- add basic telemetry instrumetation
- improve examples in hex docs

## v0.1.0 (2023-11-02)

### First release

- Published on hex.pm