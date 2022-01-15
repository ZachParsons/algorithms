defmodule Algorithms.Fibonacci do

  def run(0), do: 1
  def run(1), do: 1
  def run(n), do: run(1, 1, n)

  def run(last, _prev, 1), do: last
  def run(last, prev, n), do: run(last + prev, last, n - 1)
end
