defmodule ShortestCommonSupersequence do
  @moduledoc """
  This is the code challenge prompt:
  ```
  Given two strings A and B, find the smallest string C that contains both A and B. The characters of A and B have to appear in order, but not contiguously, within C.


  A: Jealous
  B: Jewel
  C: Jeawelous, Jewealous, Jewaelous (any of)

  A: Park
  B: Polka
  C: Parolka, Polarka, Poalrka... (any of)
  """

  def run(s1, s2) do
    chars1 = String.graphemes(s1)
    chars2 = String.graphemes(s2)

    compare([], chars1, chars2)
    |> Enum.reverse()
    |> Enum.join()
  end

  def compare([], [], []), do: []

  def compare([], [a | t2], [a | t3]), do: compare([a], t2, t3)
  def compare([], [h2 | t2], [h3 | t3]), do: compare([h2, h3], t2, t3)
  def compare(acc, [], []), do: acc

  def compare(acc, [], [h3 | t3]), do: compare([h3 | acc], [], t3)
  def compare(acc = [a | _t1], [], [a | t3]), do: compare(acc, [], t3)

  def compare(acc = [a | _t1], [a | t2], []), do: compare(acc, t2, [])
  def compare(acc, [h2 | t2], []), do: compare([h2 | acc], t2, [])

  # Non-empties.
  def compare(acc, [a | t2], [a | t3]), do: compare([a | acc], t2, t3)

  def compare(acc = [a | _t1], [a | t2], [a | t3]), do: compare(acc, t2, t3)
  def compare(acc = [a | _t1], [a | t2], chars2), do: compare(acc, t2, chars2)
  def compare(acc = [a | _t1], chars1, [a | t3]), do: compare(acc, chars1, t3)

  # Most unique case.
  def compare(acc, [h2 | t2], [h3 | t3]), do: compare([h2, h3 | acc], t2, t3)

  # Add new implementation below:
  def shortest_common_supersequence(str1, str2) do
    str1_length = String.length(str1)
    str2_length = String.length(str2)

    # Create a 2D matrix to store the lengths of the longest common subsequences
    dp_matrix = for _ <- 0..str1_length, do: List.duplicate(0, str2_length + 1)

    # Build the matrix with the lengths of the longest common subsequences
    dp_matrix =
      Enum.reduce(1..str1_length, dp_matrix, fn i, matrix ->
        Enum.reduce(1..str2_length, matrix, fn j, acc ->
          updated_value =
            if String.at(str1, i - 1) == String.at(str2, j - 1) do
              matrix_get(acc, i - 1, j - 1) + 1
            else
              max(matrix_get(acc, i - 1, j), matrix_get(acc, i, j - 1))
            end

          List.update_at(acc, i, fn row -> List.replace_at(row, j, updated_value) end)
        end)
      end)

    # Backtrack through the matrix to find the shortest common supersequence
    {supersequence, _, _} = backtrack(dp_matrix, str1, str2, str1_length, str2_length, [])

    # Reverse the list and join it to form the final supersequence string
    # |> String.reverse()
    supersequence |> Enum.join()
  end

  # Helper function to get value from 2D matrix at position [i, j]
  defp matrix_get(matrix, i, j) do
    matrix |> Enum.at(i) |> Enum.at(j)
  end

  defp backtrack(_dp_matrix, _str1, _str2, 0, 0, acc), do: {acc, 0, 0}

  defp backtrack(dp_matrix, str1, str2, 0, j, acc) do
    char = String.at(str2, j - 1)
    backtrack(dp_matrix, str1, str2, 0, j - 1, [char | acc])
  end

  defp backtrack(dp_matrix, str1, str2, i, 0, acc) do
    char = String.at(str1, i - 1)
    backtrack(dp_matrix, str1, str2, i - 1, 0, [char | acc])
  end

  defp backtrack(dp_matrix, str1, str2, i, j, acc) do
    cond do
      matrix_get(dp_matrix, i, j) == matrix_get(dp_matrix, i - 1, j) ->
        char = String.at(str1, i - 1)
        backtrack(dp_matrix, str1, str2, i - 1, j, [char | acc])

      matrix_get(dp_matrix, i, j) == matrix_get(dp_matrix, i, j - 1) ->
        char = String.at(str2, j - 1)
        backtrack(dp_matrix, str1, str2, i, j - 1, [char | acc])

      true ->
        char = String.at(str1, i - 1)
        backtrack(dp_matrix, str1, str2, i - 1, j - 1, [char | acc])
    end
  end
end
