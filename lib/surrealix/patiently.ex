defmodule Surrealix.Patiently do
  alias Surrealix.Patiently
  ## https://github.com/dantswain/patiently/blob/main/lib/patiently.ex
  @moduledoc false
  @type iteration :: (-> term)
  @type reducer :: (term -> term)
  @type predicate :: (term -> boolean)
  @type condition :: (-> boolean)
  @type opt :: {:dwell, pos_integer} | {:max_tries, pos_integer}
  @type opts :: [opt]

  defmodule GaveUp do
    @moduledoc """
    Exception raised by Patiently when a condition fails to converge
    """

    defexception message: nil
    @type t :: %__MODULE__{__exception__: true}

    @doc false
    @spec exception({pos_integer, pos_integer}) :: t
    def exception({dwell, max_tries}) do
      message =
        "Gave up waiting for condition after #{max_tries} " <>
          "iterations waiting #{dwell} msec between tries."

      %Patiently.GaveUp{message: message}
    end
  end

  @default_dwell 100
  @default_tries 10

  @spec wait_for(condition, opts) :: :ok | :error
  def wait_for(condition, opts \\ []) do
    wait_while(condition, & &1, opts)
  end

  @spec wait_for!(condition, opts) :: :ok | no_return
  def wait_for!(condition, opts \\ []) do
    ok_or_raise(wait_for(condition, opts), opts)
  end

  @spec wait_for(iteration, predicate, opts) :: :ok | :error
  def wait_for(iteration, condition, opts) do
    wait_while(iteration, condition, opts)
  end

  @spec wait_for!(iteration, predicate, opts) :: :ok | no_return
  def wait_for!(iteration, condition, opts) do
    ok_or_raise(wait_for(iteration, condition, opts), opts)
  end

  @spec wait_reduce(reducer, predicate, term, opts) :: {:ok, term} | {:error, term}
  def wait_reduce(reducer, predicate, acc0, opts) do
    wait_reduce_loop(reducer, predicate, acc0, 0, opts)
  end

  @spec wait_reduce!(reducer, predicate, term, opts) :: {:ok, term} | no_return
  def wait_reduce!(reducer, predicate, acc0, opts) do
    ok_or_raise(wait_reduce_loop(reducer, predicate, acc0, 0, opts), opts)
  end

  @spec wait_flatten(iteration, predicate | pos_integer, opts) :: {:ok, [term]} | {:error, [term]}
  def wait_flatten(iteration, predicate, opts \\ [])

  def wait_flatten(iteration, min_length, opts) when is_integer(min_length) and min_length > 0 do
    wait_flatten(iteration, fn acc -> length(acc) >= min_length end, opts)
  end

  def wait_flatten(iteration, predicate, opts) when is_function(predicate, 1) do
    reducer = fn acc -> List.flatten([iteration.() | acc]) end
    wait_reduce_loop(reducer, predicate, [], 0, opts)
  end

  @spec wait_flatten!(iteration, predicate | pos_integer, opts) :: {:ok, [term]} | no_return
  def wait_flatten!(iteration, predicate_or_min_length, opts) do
    ok_or_raise(wait_flatten(iteration, predicate_or_min_length, opts), opts)
  end

  @spec wait_for_death(pid, opts) :: :ok | :error
  def wait_for_death(pid, opts \\ []) do
    wait_for(fn -> !Process.alive?(pid) end, opts)
  end

  @spec wait_for_death!(pid, opts) :: :ok | no_return
  def wait_for_death!(pid, opts \\ []) do
    ok_or_raise(wait_for_death(pid, opts), opts)
  end

  defp ok_or_raise(:ok, _), do: :ok
  defp ok_or_raise({:ok, acc}, _), do: {:ok, acc}

  defp ok_or_raise(:error, opts) do
    raise Patiently.GaveUp, {dwell(opts), max_tries(opts)}
  end

  defp ok_or_raise({:error, _}, opts) do
    raise Patiently.GaveUp, {dwell(opts), max_tries(opts)}
  end

  defp just_status({:ok, _}), do: :ok
  defp just_status({:error, _}), do: :error

  defp wait_while(poller, condition, opts) do
    reducer = fn acc -> [poller.() | acc] end
    predicate = fn [most_recent | _] -> condition.(most_recent) end
    ok_or_err = wait_reduce_loop(reducer, predicate, [], 0, opts)
    just_status(ok_or_err)
  end

  defp wait_reduce_loop(reducer, predicate, acc, tries, opts) do
    acc_out = reducer.(acc)

    if predicate.(acc_out) do
      {:ok, acc_out}
    else
      if tries >= max_tries(opts) do
        {:error, acc_out}
      else
        :timer.sleep(dwell(opts))
        wait_reduce_loop(reducer, predicate, acc_out, tries + 1, opts)
      end
    end
  end

  defp dwell(opts) do
    Keyword.get(opts, :dwell, @default_dwell)
  end

  defp max_tries(opts) do
    Keyword.get(opts, :max_tries, @default_tries)
  end
end
