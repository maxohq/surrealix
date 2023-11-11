# @callback handle_connect(conn :: WebSockex.Conn.t(), state :: term) :: {:ok, new_state :: term}
# @callback handle_disconnect(connection_status_map, state :: term) ::
#               {:ok, new_state}
#               | {:reconnect, new_state}
#               | {:reconnect, new_conn :: WebSockex.Conn.t(), new_state}
#             when new_state: term
# @callback terminate(close_reason, state :: term) :: any

defmodule Sand do
  def run do
    # {:ok, pid} = Surrealix.start(namespace: "test", database: "test", debug: [:trace])
    {:ok, pid} =
      Surrealix.start(
        namespace: "test",
        database: "test",
        on_connect: fn pid, _state ->
          IO.puts("GOT PID: #{inspect(pid)}")
          IO.puts("SIGNIN...")
          Surrealix.signin(pid, %{user: "root", pass: "root"}) |> IO.inspect()
          IO.puts("USE...")
          Surrealix.use(pid, "test", "test") |> IO.inspect()
        end,
        async: true
      )

    Surrealix.query(pid, "select * from user")

    # Surrealix.live_query(pid, "LIVE SELECT * FROM user;", fn data, query_id ->
    #   IO.inspect({data, query_id}, label: "callback")
    # end)

    Surrealix.stop(pid)
  end
end
