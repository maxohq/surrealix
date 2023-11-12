defmodule Sand do
  def run do
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

    # now we can execute normal "CRUD" queries
    Surrealix.live_query(pid, "LIVE SELECT * FROM user;", fn data, query_id ->
      IO.inspect({data, query_id}, label: "callback")
    end)

    Surrealix.live_query(pid, "LIVE SELECT * FROM person;", fn data, query_id ->
      IO.inspect({data, query_id}, label: "callback")
    end)
  end
end
