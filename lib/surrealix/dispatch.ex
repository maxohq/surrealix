defmodule Surrealix.Dispatch do
  @moduledoc """
  Handles callback registration (for only when using live queries).
  Based on ideas here: https://github.com/keathley/sync_dispatch
    - which itself is based on :telemetry (https://hex.pm/packages/telemetry) implementation.
  """

  alias Surrealix.HandlerTable

  @type handler_function :: (list(atom()), term(), term() -> any())

  @doc """
  Executes an event and any handlers that are attached to the event name. `data`
  can be any term().
  """
  @spec execute(list(atom()), term()) :: :ok | no_return()
  def execute(event, data) do
    handlers = HandlerTable.handlers_for_event(event)

    for {handler, event, config} <- handlers do
      handler.(event, data, config)
    end

    :ok
  end

  @doc """
  Attaches a function to an event. The provided id is used for idempotence.
  Different handlers should use unique handler ids.
  """
  @spec attach(term(), list(atom()), handler_function(), term()) ::
          :ok | {:error, %Surrealix.AttachError{}}
  def attach(id, event, fun, config \\ nil) do
    HandlerTable.insert(id, event, fun, config)
  end

  def remove(id) do
    HandlerTable.remove(id)
  end
end
