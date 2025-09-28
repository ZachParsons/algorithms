defmodule Algorithms.NQueens.Backtracking do
  @moduledoc """
  The n-queens puzzle is the problem of placing n queens on an n x n chessboard such that no two queens attack each other.

  Given an integer n, return all distinct solutions to the n-queens puzzle. You may return the answer in any order.

  Each solution contains a distinct board configuration of the n-queens' placement, where 'Q' and '.' both indicate a queen and an empty space, respectively.

  ## Implementation Comparison

  This module provides two different algorithmic approaches:

  ### `run0/1` - Row-by-Row Constraint Propagation
  - **Search Strategy**: Processes one row at a time sequentially
  - **Branching**: Uses `Enum.reduce/3` to try only safe columns, single recursive path per valid position
  - **Constraint Checking**: Proactive validation with `safe?/3` before placing queens
  - **Performance**: O(n!) time complexity with early pruning, more memory efficient
  - **Architecture**: Classic backtracking optimized for N-Queens constraints

  ### `run1/1` - Coordinate Space Exploration
  - **Search Strategy**: Explores entire coordinate space systematically `{i,j}`
  - **Branching**: Dual recursion exploring both "place queen" and "skip position" paths
  - **Constraint Checking**: Reactive validation with `attacked?/3` after placement attempts
  - **Performance**: O(2^(n²)) time complexity, larger search space with late pruning
  - **Architecture**: Generic coordinate-space search adaptable to other grid problems

  **Recommendation**: Use `run0/1` for efficiency, `run1/1` for educational purposes or as a template for similar grid-based constraint problems.
  """

  ## Mnemonic for run0
  # Data Flow: n → positions list → solutions list → MapSet → formatted boards
  # Iteration: solve(row=0..n) → reduce(col=0..n-1) → recurse deeper
  #   Guard clause: row==n → collect solution
  #   Reduce loop: test each column position
  # Decision Logic: safe? → branch execution
  #   True: [{row,col}|positions] → solve(row+1)
  #   False: skip column → continue reduce
  #   Format: positions → MapSet lookup → board strings

  def run0(n) do
    do_run(n, 0, [], [])
  end

  # Main solving function using backtracking
  defp do_run(n, row, positions, solutions) when row == n do
    # Base case: all queens placed, add this solution
    [format_solution(positions, n) | solutions]
  end

  defp do_run(n, row, positions, solutions) do
    # Try placing a queen in each column of the current row
    0..(n - 1)
    |> Enum.reduce(solutions, fn col, acc ->
      if safe?(positions, row, col) do
        # Place queen and recurse to next row
        do_run(n, row + 1, [{row, col} | positions], acc)
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

  # Alternative implementation using coordinate iteration
  # Mnemonic for run1:
  # Data Flow: n → board coordinates → solutions list → normalized boards
  # Iteration: solve({i,j}) → try position → recurse {i+1,0} or {i,j+1}
  #   Guard: {n,0} → collect board, {_,n} → backtrack
  #   Branch: attacked? → skip position, safe → add queen + recurse down
  # Decision Logic: column/diagonal conflicts → branch execution
  #   True: continue to next column {i,j+1}
  #   False: place queen → solve({i+1,0}) + solve({i,j+1})
  def run1(n) do
    solve([], n, {0, 0}, []) |> Enum.map(&normalize(&1, n))
  end

  # A board is just a bunch of coordinates where a queen resides.
  defp solve(board, n, {n, 0}, acc), do: [board | acc]
  defp solve(_board, n, {_, n}, acc), do: acc

  defp solve(board, n, {i, j}, acc) do
    acc =
      if attacked?(board, {i, j}) do
        acc
      else
        solve([{i, j} | board], n, {i + 1, 0}, acc)
      end

    solve(board, n, {i, j + 1}, acc)
  end

  defp attacked?(board, {i, j}) do
    Enum.any?(board, fn {ii, jj} ->
      jj == j or
        ii - jj == i - j or
        ii + jj == i + j
    end)
  end

  defp normalize(board, n) do
    for {{x, y}, i} <- Enum.with_index(board) do
      0..(n - 1)
      |> Enum.map(fn j ->
        if {n - i - 1, j} == {x, y}, do: "Q", else: "."
      end)
      |> IO.iodata_to_binary()
    end
  end
end
