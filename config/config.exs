import Config

# config :surrealix, :logger,

config :logger, :console,
  format: "[$level] $message\n",
  # level: :debug

  level: :warning

config :surrealix, :conn,
  hostname: "0.0.0.0",
  port: 8000
