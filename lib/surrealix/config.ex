defmodule Surrealix.Config do
  @moduledoc """
  Explicit config module to keep configurable options in a single place
  """
  @type socket_opts :: [
          hostname: String.t(),
          port: integer(),
          namespace: String.t(),
          database: String.t(),
          username: String.t(),
          password: String.t()
        ]

  @type base_connection_opts :: socket_opts()
  @base_connection_opts Application.compile_env(:surrealix, :conn,
                          hostname: "0.0.0.0",
                          port: 8000
                        )

  def base_conn_opts, do: @base_connection_opts

  @timeout Application.compile_env(:surrealix, :timeout, 5000)

  def default_timeout, do: @timeout
  def task_opts_default, do: [timeout: @timeout]

  @backoff_max Application.compile_env(:surrealix, :backoff_max, 2000)
  @backoff_step Application.compile_env(:surrealix, :backoff_step, 50)
  def backoff_max, do: @backoff_max
  def backoff_step, do: @backoff_step
end
