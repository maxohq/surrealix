defmodule Surrealix.AttachError do
  @moduledoc false
  defexception [:message]

  @impl true
  def exception(msg) do
    %__MODULE__{message: msg}
  end
end
