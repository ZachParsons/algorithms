defmodule Algorithms.Sets.SubsetEqualSumTest do
  use ExUnit.Case
  alias Algorithms.Sets.SubsetEqualSum

  test "success" do
    input = [1, 5, 11, 5]
    assert SubsetEqualSum.run(input)

    input = [1, 2, 5]
    refute SubsetEqualSum.run(input)
  end
end
