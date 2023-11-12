defmodule Sand do
  def run do
    {:ok, pid} =
      Surrealix.start(
        on_connect: fn pid, _state ->
          IO.puts("PID: #{inspect(pid)}")
          Surrealix.signin(pid, %{user: "root", pass: "root"}) |> IO.inspect(label: :signin)
          Surrealix.use(pid, "test", "test") |> IO.inspect(label: :use)
        end
      )

    Surrealix.Patiently.wait_for(fn -> :sys.get_state(pid) |> Map.get(:connected) == true end)

    Surrealix.live_query(pid, "LIVE SELECT * FROM user;", fn data, query_id ->
      IO.inspect({data, query_id}, label: "callback")
    end)

    Surrealix.live_query(pid, "LIVE SELECT * FROM person;", fn data, query_id ->
      IO.inspect({data, query_id}, label: "callback")
    end)
  end
end
