defmodule Surrealix.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Surrealix.Dispatch.HandlerTable, []}
    ]

    opts = [strategy: :one_for_one, name: Surrealix.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
