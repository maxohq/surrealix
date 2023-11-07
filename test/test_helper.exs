ExUnit.start()

defmodule TestSupport do
  def extract_res({:ok, res}) do
    Map.get(res, "result")
  end

  def extract_res({:ok, res}, index) do
    extract_res({:ok, res}) |> Enum.at(index) |> Map.get("result")
  end

  def db_name(), do: for(_ <- 1..10, into: "", do: <<Enum.random(~c"0123456789abcdef")>>)

  def with_cleanup(fun) do
    db = db_name()
    {:ok, pid} = Surrealix.start_link()
    Surrealix.signin(pid, %{user: "root", pass: "root"})
    Surrealix.use(pid, "test", db)

    fun.(pid)

    res = Surrealix.query(pid, "remove database #{db};")
    IO.inspect(res, label: :res)
    Surrealix.stop(pid)
  end
end
