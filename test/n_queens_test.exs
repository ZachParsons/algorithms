defmodule Algorithms.NQueensTest do
  use ExUnit.Case
  alias Algorithms.NQueens.Backtracking

  test "board: 4x4" do
    input = 4

    expected = [
      [".Q..", "...Q", "Q...", "..Q."],
      ["..Q.", "Q...", "...Q", ".Q.."]
    ]

    res = Backtracking.run(input)

    # Since solutions can be returned in any order, we need to check if the result contains the expected solutions
    assert length(res) == 2

    assert Enum.all?(
             expected,
             fn solution -> solution in res end
           )
  end

  test "board: 1x1" do
    input = 1
    expected = [["Q"]]
    res = Backtracking.run(input)
    assert expected == res
  end
end
