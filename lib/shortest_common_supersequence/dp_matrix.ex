defmodule ShortestCommonSupersequence.DPMatrix do
  @moduledoc """
  Dynamic Programming Solution (Using Matrix Approach)

  Algorithm:
  1. Build a DP matrix to find the longest common subsequence (LCS)
  2. Use the DP matrix to construct the shortest common supersequence

  Time Complexity: O(m*n) where m, n are lengths of input strings
  Space Complexity: O(m*n) for the DP matrix

  Mnemonic:
  Build:    strings → charlists, flat :array[(m+1)*(n+1)] zeros, index = i*(n+1)+j
  Fill:     each (i,j) — match → 1 + arr[i-1,j-1]; no match → max(arr[i-1,j], arr[i,j-1])
  Backtrack from (m,n):
    match        → prepend char, step diagonal (i-1, j-1)
    no match     → follow larger neighbor, prepend that string's char
    i=0 or j=0  → drain remaining string
  Return: charlist → string
  """

  @spec run(s1 :: String.t(), s2 :: String.t()) :: String.t()
  def run(s1, s2) do
    s1 |> build_dp_matrix(s2) |> construct_supersequence(s1, s2)
  end

  defp build_dp_matrix(s1, s2) do
    m = String.length(s1)
    n = String.length(s2)

    s1_chars = String.to_charlist(s1)
    s2_chars = String.to_charlist(s2)

    arr = :array.new((m + 1) * (n + 1), default: 0)

    Enum.reduce(for(i <- 1..m//1, j <- 1..n//1, do: {i, j}), arr, fn {i, j}, acc ->
      char1 = Enum.at(s1_chars, i - 1)
      char2 = Enum.at(s2_chars, j - 1)

      new_value =
        if char1 == char2 do
          1 + get_cell(acc, i - 1, j - 1, n)
        else
          max(get_cell(acc, i - 1, j, n), get_cell(acc, i, j - 1, n))
        end

      :array.set(cell(i, j, n), new_value, acc)
    end)
  end

  defp cell(i, j, n), do: i * (n + 1) + j
  defp get_cell(arr, i, j, n), do: :array.get(cell(i, j, n), arr)

  defp construct_supersequence(arr, s1, s2) do
    m = String.length(s1)
    n = String.length(s2)

    backtrack(arr, String.to_charlist(s1), String.to_charlist(s2), m, n, [], n)
    |> to_string()
  end

  defp backtrack(_arr, _s1, _s2, 0, 0, acc, _n), do: acc

  defp backtrack(arr, s1, s2, 0, j, acc, n) do
    backtrack(arr, s1, s2, 0, j - 1, [Enum.at(s2, j - 1) | acc], n)
  end

  defp backtrack(arr, s1, s2, i, 0, acc, n) do
    backtrack(arr, s1, s2, i - 1, 0, [Enum.at(s1, i - 1) | acc], n)
  end

  defp backtrack(arr, s1, s2, i, j, acc, n) do
    char1 = Enum.at(s1, i - 1)
    char2 = Enum.at(s2, j - 1)

    cond do
      char1 == char2 ->
        backtrack(arr, s1, s2, i - 1, j - 1, [char1 | acc], n)

      get_cell(arr, i - 1, j, n) > get_cell(arr, i, j - 1, n) ->
        backtrack(arr, s1, s2, i - 1, j, [char1 | acc], n)

      true ->
        backtrack(arr, s1, s2, i, j - 1, [char2 | acc], n)
    end
  end
end
