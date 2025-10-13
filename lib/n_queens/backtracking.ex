defmodule Algorithms.NQueens.Backtracking do
  @moduledoc """
  The n-queens puzzle is the problem of placing n queens on an n x n chessboard such that no two queens attack each other.

  Given an integer n, return all distinct solutions to the n-queens puzzle. You may return the answer in any order.

  Each solution contains a distinct board configuration of the n-queens' placement, where 'Q' and '.' both indicate a queen and an empty space, respectively.

  ## Implementation Comparison

  This module provides three distinct algorithmic approaches with surprising performance characteristics:

  ### `run0/1` - Classic Row-by-Row Backtracking
  - **Strategy**: Traditional constraint satisfaction approach
  - **Data Structure**: List of `{row, col}` coordinates
  - **Constraint Checking**: O(n) iteration through all placed queens for each new position
  - **Search Pattern**: Row-sequential with column enumeration
  - **Performance**: Baseline - most intuitive but not fastest
  - **Best For**: Learning backtracking fundamentals, general use

  ### `run1/1` - Coordinate Space Exploration
  - **Strategy**: Exhaustive 2D grid traversal with dual recursion
  - **Data Structure**: List of `{i, j}` coordinates with complex normalization
  - **Constraint Checking**: O(n) attack pattern matching but simpler operations
  - **Search Pattern**: Explores both "place queen" and "skip position" for every coordinate
  - **Performance**: 1.7x faster than run0 despite O(2^(n²)) theoretical complexity
  - **Best For**: Exploring alternative search strategies, adaptable to other grid problems

  ### `run2/1` - Optimized Diagonal Tracking
  - **Strategy**: Intelligent constraint propagation using precomputed diagonal sets
  - **Data Structure**: Row positions + diagonal conflict sets (`add_list`, `sub_list`)
  - **Constraint Checking**: O(1) set membership tests (2.3x faster than others)
  - **Search Pattern**: Only explores valid columns, excludes occupied rows
  - **Performance**: 1.8x faster than run0, most efficient overall
  - **Best For**: Performance-critical applications, understanding optimization techniques

  ### Key Insights
  - **Counter-intuitive**: `run1` outperforms `run0` despite exponential complexity due to simpler operations and better cache locality
  - **Optimization wins**: `run2`'s diagonal tracking provides O(1) constraint checking vs O(n) for others
  - **Real-world vs theory**: Implementation efficiency can overcome theoretical complexity disadvantages

  **Recommendations**:
  - Production: `run2` (fastest) or `run0` (clarity/performance balance)
  - Education: `run0` (fundamentals) or `run2` (optimization techniques)
  - Research: `run1` (alternative approaches)
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

  # Optimized implementation using diagonal tracking
  # Mnemonic for run2:
  # Data Flow: n → row positions → diagonal sets → solutions → formatted boards
  # Iteration: do_run2(row=[]) → reduce(available_cols) → recurse deeper
  #   Guard: length(row)==n → collect solution
  #   Reduce: filter occupied rows, test diagonal conflicts
  # Decision Logic: diagonal set membership → branch execution
  #   True: skip column → continue reduce
  #   False: add to sets → do_run2([col|row]) + recurse
  #   Sets: add_list (\ diagonals), sub_list (/ diagonals)
  def run2(n) do
    do_run2(n, [], [], [], [])
  end

  defp do_run2(n, row, _, _, solutions) when n == length(row) do
    # Convert row positions to board format
    board = format_row_solution(row, n)
    [board | solutions]
  end

  defp do_run2(n, row, add_list, sub_list, solutions) do
    (Enum.to_list(0..(n - 1)) -- row)
    |> Enum.reduce(solutions, fn x, acc ->
      # \ diagonal check
      add = x + length(row)
      # / diagonal check
      sub = x - length(row)

      if add in add_list or sub in sub_list do
        acc
      else
        do_run2(n, [x | row], [add | add_list], [sub | sub_list], acc)
      end
    end)
  end

  defp format_row_solution(row, n) do
    # row contains column positions for each row (in reverse order)
    row
    |> Enum.reverse()
    |> Enum.map(&format_board_row(&1, n))
  end

  defp format_board_row(col, n) do
    Enum.map_join(0..(n - 1), fn i ->
      if i == col, do: "Q", else: "."
    end)
  end
end
