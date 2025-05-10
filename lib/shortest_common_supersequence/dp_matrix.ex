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
    # Get the lengths of both strings
    m = String.length(s1)
    n = String.length(s2)

    # Step 1: Create and fill the DP matrix for LCS
    dp = build_dp_matrix(s1, s2, m, n)

    # Step 2: Construct the shortest common supersequence from the DP matrix
    construct_supersequence(dp, s1, s2, m, n)
  end

  # Builds the DP matrix for finding the longest common subsequence
  defp build_dp_matrix(s1, s2, m, n) do
    # Initialize matrix with zeros
    dp = for _ <- 0..m, do: List.duplicate(0, n + 1)

    # Fill the dp matrix
    dp =
      Enum.reduce(1..m, dp, fn i, dp ->
        Enum.reduce(1..n, dp, fn j, dp ->
          dp_row = Enum.at(dp, i)

          # Check if characters match
          new_value =
            if String.at(s1, i - 1) == String.at(s2, j - 1) do
              1 + get_matrix_value(dp, i - 1, j - 1)
            else
              max(get_matrix_value(dp, i - 1, j), get_matrix_value(dp, i, j - 1))
            end

          # Update the dp matrix
          List.replace_at(dp, i, List.replace_at(dp_row, j, new_value))
        end)
      end)

    dp
  end

  # Helper function to get value from matrix at position (i, j)
  defp get_matrix_value(matrix, i, j) do
    matrix |> Enum.at(i) |> Enum.at(j)
  end

  # Construct the shortest common supersequence using the DP matrix
  defp construct_supersequence(dp, s1, s2, m, n) do
    # Start from the bottom right of the dp matrix
    {result, _, _} =
      build_result(dp, s1, s2, m, n, [])

    # Convert the result list to a string
    result
    |> List.to_string()
  end

  # Build the result by backtracking through the DP matrix
  defp build_result(_dp, s1, s2, i, j, result) when i == 0 and j == 0, do: {result, i, j}

  defp build_result(dp, s1, s2, i, j, result) do
    cond do
      # If we've used all characters from s1, take remaining from s2
      i == 0 ->
        build_result(dp, s1, s2, i, j - 1, [String.at(s2, j - 1) | result])

      # If we've used all characters from s2, take remaining from s1
      j == 0 ->
        build_result(dp, s1, s2, i - 1, j, [String.at(s1, i - 1) | result])

      # If characters match, add once and move diagonally
      String.at(s1, i - 1) == String.at(s2, j - 1) ->
        build_result(dp, s1, s2, i - 1, j - 1, [String.at(s1, i - 1) | result])

      # If characters don't match, take from the direction that has greater LCS value
      get_matrix_value(dp, i - 1, j) > get_matrix_value(dp, i, j - 1) ->
        build_result(dp, s1, s2, i - 1, j, [String.at(s1, i - 1) | result])

      # Otherwise take from s2
      true ->
        build_result(dp, s1, s2, i, j - 1, [String.at(s2, j - 1) | result])
    end
  end
end
