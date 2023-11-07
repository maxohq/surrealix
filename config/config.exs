import Config

# config :surrealix, :logger,

config :logger, :console,
  format: "[$level] $message\n",
  # level: :debug

  level: :warning
