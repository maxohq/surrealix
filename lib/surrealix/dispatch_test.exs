defmodule Surrealix.DispatchTest do
  # cant be async, uses a global gen ETS table!
  use ExUnit.Case
  alias Surrealix.Dispatch

  setup do
    Surrealix.HandlerTable.start_link([])
    Surrealix.HandlerTable.delete_all()

    :ok
  end

  test "dispatches events" do
    us = self()

    Dispatch.attach("handler-one", [:event, :prefix], fn event, data, config ->
      send(us, {:first, event, data, config})
    end)

    Dispatch.attach(
      "handler-two",
      [:event, :prefix],
      fn event, data, config ->
        send(us, {:second, event, data, config})
      end,
      :two
    )

    Dispatch.execute([:event, :prefix], %{test: true})

    assert_receive {:first, event, data, config}
    assert event == [:event, :prefix]
    assert data == %{test: true}
    assert config == nil

    assert_receive {:second, event, data, config}
    assert event == [:event, :prefix]
    assert data == %{test: true}
    assert config == :two
  end

  test "re-using event ids produces an error" do
    assert :ok = Dispatch.attach("handler", [:event, :prefix], fn _, _, _ -> nil end)

    assert {:error, error} =
             Dispatch.attach("handler", [:event, :prefix], fn _, _, _ -> nil end)

    assert match?(%Surrealix.AttachError{}, error)
  end
end
