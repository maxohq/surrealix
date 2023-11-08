defmodule Surrealix.TelemetryTest do
  use ExUnit.Case

  ## https://samuelmullen.com/articles/elixir-telemetry-metrics-and-reporters
  ## https://keathley.io/blog/telemetry-conventions.html
  ## https://github.com/whatyouhide/redix/blob/main/lib/redix/telemetry.ex
  ## https://hexdocs.pm/oban/Oban.Telemetry.html
  ## https://github.com/elixir-tesla/tesla/blob/master/lib/tesla/middleware/telemetry.ex
  ## https://thoughtbot.com/blog/instrumenting-your-phoenix-application-using-telemetry
  ## https://elixirschool.com/blog/instrumenting-phoenix-with-telemetry-part-one/
  ## https://blog.miguelcoba.com/telemetry-and-metrics-in-elixir
  ## https://til.hashrocket.com/posts/u2pizangdk-telemetry-attach-and-execute
  #   #   import ExUnit.CaptureLog

  #   test "telemetry events" do
  #     {test_name, _arity} = __ENV__.function
  #     parent = self()
  #     ref = make_ref()

  #     handler = fn event, measurements, _meta, _config ->
  #       assert event == [:surrealix, :name, :start]
  #       assert is_integer(measurements.system_time)
  #       send(parent, {ref, :start})
  #     end

  #     :telemetry.attach_many(
  #       to_string(test_name),
  #       [
  #         [:your_app, :name, :start]
  #       ],
  #       handler,
  #       nil
  #     )

  #     # some function call...

  #     assert_receive {^ref, :start}
  #     assert_receive {^ref, :stop}
  #   end
end
