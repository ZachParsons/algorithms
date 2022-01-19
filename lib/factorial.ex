defmodule Algorithms.Factorial do
  def run(0), do: 0

  def run(i)
      when is_integer(i) and i > 0 do
    Enum.reduce(1..i, 1, &*/2)
  end

  def run(_), do: "invalid input"
end
