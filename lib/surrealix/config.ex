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
                          port: 8000,
                          namespace: "default",
                          database: "default",
                          username: "root",
                          password: "root"
                        )

  def base_conn_opts, do: @base_connection_opts

  def task_opts_default, do: [timeout: :infinity]
end
