ExUnit.start()

defmodule TestSupport do
  def extract_res({:ok, res}) do
    Map.get(res, "result")
  end

  def extract_res({:ok, res}, index) do
    extract_res({:ok, res}) |> Enum.at(index) |> Map.get("result")
  end

  def db_name() do
    rand =
      :crypto.strong_rand_bytes(6)
      |> Base.encode64()

    "test_#{Regex.replace(~r/\W/, rand, "")}"
  end

  def with_cleanup(fun) do
    db = db_name()
    # IO.puts("*********** DB: #{db}")
    {:ok, pid} = Surrealix.start_link()
    Surrealix.signin(pid, %{user: "root", pass: "root"})
    Surrealix.use(pid, "test", db)

    fun.(pid)

    _res = Surrealix.query(pid, "remove database #{db};")
    # IO.inspect(res, label: :res)
    Surrealix.stop(pid)
  end
end
