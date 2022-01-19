defmodule Algorithms.CombinationsTest do
  use ExUnit.Case
  alias Algorithms.Combinations

  test "success: 4, 2" do
    assert [
             [:a, :b],
             [:a, :c],
             [:a, :d],
             [:b, :c],
             [:b, :d],
             [:c, :d]
           ] == Combinations.run([:a, :b, :c, :d], 2)
  end

  test "success: 4, 3" do
    assert [
             [:a, :b, :c],
             [:a, :b, :d],
             [:a, :c, :d],
             [:b, :c, :d]
           ] == Combinations.run([:a, :b, :c, :d], 3)
  end

  test "failure: invalid elements" do
    assert "invalid input" == Combinations.run(%{}, 2)
  end

  test "failure: invalid size" do
    assert "invalid input" == Combinations.run([:a], 1.5)
  end
end
