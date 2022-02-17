defmodule Algorithms.OnlyEvery do
  # run(1..10, 5, 2)
  def run(range, only, every) do
    range
    |> Enum.take_every(every)
    |> Enum.take(only)
  end
end
