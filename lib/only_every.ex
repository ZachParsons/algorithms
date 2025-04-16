defmodule Algorithms.OnlyEvery do
  @moduledoc false
  # run(1..10, 5, 2)
  def run(range, only, every) do
    range
    |> Enum.take_every(every)
    |> Enum.take(only)
  end
end
