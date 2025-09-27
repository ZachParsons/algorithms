defmodule Algorithms.NQueens.Backtracking do
  @moduledoc """
  The n-queens puzzle is the problem of placing n queens on an n x n chessboard such that no two queens attack each other.

  Given an integer n, return all distinct solutions to the n-queens puzzle. You may return the answer in any order.

  Each solution contains a distinct board configuration of the n-queens' placement, where 'Q' and '.' both indicate a queen and an empty space, respectively.
  """

  def run(n) do
    solve(n, 0, [], [])
  end

  # Main solving function using backtracking
  defp solve(n, row, positions, solutions) when row == n do
    # Base case: all queens placed, add this solution
    [format_solution(positions, n) | solutions]
  end

  defp solve(n, row, positions, solutions) do
    # Try placing a queen in each column of the current row
    0..(n - 1)
    |> Enum.reduce(solutions, fn col, acc ->
      if safe?(positions, row, col) do
        # Place queen and recurse to next row
        solve(n, row + 1, [{row, col} | positions], acc)
      else
        acc
      end
    end)
  end

  # Check if placing a queen at (row, col) is safe
  defp safe?(positions, row, col) do
    Enum.all?(positions, fn {r, c} ->
      # Not in same column
      # Not in same diagonal (slope = 1)
      c != col and
        abs(r - row) != abs(c - col)
    end)
  end

  # Convert positions to the required string format
  defp format_solution(positions, n) do
    # Create a set for quick lookup
    queen_positions = MapSet.new(positions)

    for row <- 0..(n - 1) do
      for col <- 0..(n - 1), into: "" do
        if MapSet.member?(queen_positions, {row, col}), do: "Q", else: "."
      end
    end
  end
end
