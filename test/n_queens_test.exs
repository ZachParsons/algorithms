defmodule Algorithms.NQueensTest do
  use ExUnit.Case
  alias Algorithms.NQueens.Backtracking

  test "board: 4x4" do
    input = 4

    expected = [
      [".Q..", "...Q", "Q...", "..Q."],
      ["..Q.", "Q...", "...Q", ".Q.."]
    ]

    res0 = Backtracking.run0(input)
    res1 = Backtracking.run1(input)

    # Since solutions can be returned in any order, we need to check if the result contains the expected solutions
    assert length(res0) == 2
    assert length(res1) == 2

    assert Enum.all?(
             expected,
             fn solution -> solution in res0 end
           )

    assert Enum.all?(
             expected,
             fn solution -> solution in res1 end
           )
  end

  test "board: 1x1" do
    input = 1
    expected = [["Q"]]
    res0 = Backtracking.run0(input)
    res1 = Backtracking.run1(input)
    assert expected == res0
    assert expected == res1
  end
end
