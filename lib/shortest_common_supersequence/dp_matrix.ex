defmodule ShortestCommonSupersequence.DPMatrix do
  @moduledoc """
  Dynamic Programming Solution (Using Matrix Approach)

  Algorithm:
  1. Build a DP matrix to find the longest common subsequence (LCS)
  2. Use the DP matrix to construct the shortest common supersequence

  Time Complexity: O(m*n) where m, n are lengths of input strings
  Space Complexity: O(m*n) for the DP matrix
  """

  @spec run(s1 :: String.t(), s2 :: String.t()) :: String.t()
  def run(s1, s2) do
    s1 |> build_dp_matrix(s2) |> construct_supersequence(s1, s2)
  end

  # Builds the DP matrix for finding the longest common subsequence
  @spec build_dp_matrix(s1 :: String.t(), s2 :: String.t()) :: list(list(integer()))
  defp build_dp_matrix(s1, s2) do
    m = String.length(s1)
    n = String.length(s2)

    # Convert strings to character lists for O(1) access
    s1_chars = String.to_charlist(s1)
    s2_chars = String.to_charlist(s2)

    # Initialize empty matrix of size (m+1) x (n+1)
    matrix = for _ <- 0..m, do: List.duplicate(0, n + 1)

    # Fill matrix using recursion with accumulator
    fill_matrix(matrix, s1_chars, s2_chars, m, n)
  end

  # Base case: matrix is filled
  defp fill_matrix(matrix, _s1, _s2, 0, 0), do: matrix

  # Recursive case: fill matrix row by row, column by column
  defp fill_matrix(matrix, s1, s2, m, n) do
    indices = for i <- 1..m, j <- 1..n, do: {i, j}

    Enum.reduce(indices, matrix, fn {i, j}, acc ->
      # Current character in each string (0-indexed)
      char1 = Enum.at(s1, i - 1)
      char2 = Enum.at(s2, j - 1)

      new_value =
        if char1 == char2 do
          # Characters match - increment diagonal value
          1 + get_value(acc, i - 1, j - 1)
        else
          # Characters don't match - take max of left and top
          max(get_value(acc, i - 1, j), get_value(acc, i, j - 1))
        end

      # Update matrix at position (i, j)
      update_matrix(acc, i, j, new_value)
    end)
  end

  # Get value from matrix at position (i, j)
  defp get_value(matrix, i, j), do: matrix |> Enum.at(i) |> Enum.at(j)

  # Update matrix at position (i, j) with new value
  defp update_matrix(matrix, i, j, value) do
    matrix
    |> Enum.with_index()
    |> Enum.map(&update_row_if_matches(&1, i, j, value))
  end

  defp update_row_if_matches({row, row_idx}, i, j, value) when row_idx == i do
    row
    |> Enum.with_index()
    |> Enum.map(&update_cell_if_matches(&1, j, value))
  end

  defp update_row_if_matches({row, _row_idx}, _i, _j, _value), do: row

  defp update_cell_if_matches({_cell, col_idx}, j, value) when col_idx == j, do: value
  defp update_cell_if_matches({cell, _col_idx}, _j, _value), do: cell

  # Construct the shortest common supersequence using the DP matrix
  @spec construct_supersequence(
          matrix :: list(list(integer())),
          s1 :: String.t(),
          s2 :: String.t()
        ) :: String.t()
  defp construct_supersequence(matrix, s1, s2) do
    m = String.length(s1)
    n = String.length(s2)

    # Convert strings to character lists for O(1) access
    s1_chars = String.to_charlist(s1)
    s2_chars = String.to_charlist(s2)

    # Start backtracking from bottom-right corner of matrix
    backtrack(matrix, s1_chars, s2_chars, m, n, [])
    |> to_string()
  end

  # Backtracking: Base case, reached top-left corner
  defp backtrack(_matrix, _s1, _s2, 0, 0, acc), do: acc

  # Backtracking: No more characters in first string
  defp backtrack(matrix, s1, s2, 0, j, acc) do
    backtrack(matrix, s1, s2, 0, j - 1, [Enum.at(s2, j - 1) | acc])
  end

  # Backtracking: No more characters in second string
  defp backtrack(matrix, s1, s2, i, 0, acc) do
    backtrack(matrix, s1, s2, i - 1, 0, [Enum.at(s1, i - 1) | acc])
  end

  # Backtracking: Main recursive function
  defp backtrack(matrix, s1, s2, i, j, acc) do
    char1 = Enum.at(s1, i - 1)
    char2 = Enum.at(s2, j - 1)

    cond do
      # Characters match - take one character and move diagonally
      char1 == char2 ->
        backtrack(matrix, s1, s2, i - 1, j - 1, [char1 | acc])

      # Take from first string if it leads to longer LCS
      get_value(matrix, i - 1, j) > get_value(matrix, i, j - 1) ->
        backtrack(matrix, s1, s2, i - 1, j, [char1 | acc])

      # Otherwise take from second string
      true ->
        backtrack(matrix, s1, s2, i, j - 1, [char2 | acc])
    end
  end
end
