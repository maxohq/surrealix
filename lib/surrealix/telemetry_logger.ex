defmodule Surrealix.Telemetry.Logger do
  @moduledoc """
  Telemetry Logger. Hooks telemetry events and logs them to stdout.
  """
  require Logger

  def setup do
    events = [
      [:surrealix, :exec_method, :start],
      [:surrealix, :exec_method, :stop],
      [:surrealix, :exec_method, :exception]
    ]

    :telemetry.attach_many("basic-logger", events, &handle_event/4, nil)
  end

  def handle_event(event, measurements, meta, _) do
    IO.inspect({event, measurements, meta})
  end

  def check do
    a = System.monotonic_time()
    Process.sleep(100)
    b = System.monotonic_time()
    IO.inspect({b - a, :time})
  end
end
