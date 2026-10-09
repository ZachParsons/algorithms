defmodule Algorithms.Sets.Powerset do
  def run([]), do: [[]]

  def run([head | tail]) do
    rest = run(tail)
    rest ++ Enum.map(rest, fn subset -> [head | subset] end)
  end
end
