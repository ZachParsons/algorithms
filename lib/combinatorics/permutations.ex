defmodule Algorithms.Combinatorics.Permutations do
  @moduledoc """
  A permutation is a specific type of combination where order matters.
  """

  def run(elements) when not is_list(elements), do: "invalid input"
  def run([]), do: [[]]

  def run(elements) do
    for head <- elements, tail <- run(elements -- [head]) do
      [head | tail]
    end
  end
end
