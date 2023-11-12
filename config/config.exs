import Config

config :logger, :console, format: "[$level] $message\n"
config :logger, :console, level: :warning
# config :logger, :console, level: :debug

config :surrealix, :timeout, 5000
config :surrealix, :backoff_max, 2000
config :surrealix, :backoff_step, 100

config :surrealix, :conn,
  hostname: "0.0.0.0",
  port: 8000
