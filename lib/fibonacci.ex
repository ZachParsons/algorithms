defmodule Algorithms.Fibonacci do
  @moduledoc false
  def run(0), do: 1
  def run(1), do: 1

  def run(i)
      when is_integer(i) and i > 1 do
    run(1, 1, i)
  end

  def run(_), do: "invalid input"

  defp run(last, _prev, 1), do: last
  defp run(last, prev, i), do: run(last + prev, last, i - 1)
end
