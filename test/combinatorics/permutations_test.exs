defmodule Algorithms.Combinatorics.PermutationsTest do
  use ExUnit.Case
  alias Algorithms.Combinatorics.Permutations

  test "success: 3 elements" do
    assert [
             [:a, :b, :c],
             [:a, :c, :b],
             [:b, :a, :c],
             [:b, :c, :a],
             [:c, :a, :b],
             [:c, :b, :a]
           ] == Permutations.run([:a, :b, :c])
  end

  test "failure: invalid elements" do
    assert "invalid input" == Permutations.run(%{})
  end
end
