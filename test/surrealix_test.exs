defmodule SurrealixTest do
  use ExUnit.Case
  doctest Surrealix

  test "greets the world" do
    assert Surrealix.hello() == :world
  end
end
