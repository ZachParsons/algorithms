defmodule Algorithms.LongestSubstring do
  @moduledoc """
    Given a string, find the length of the longest substring without repeating characters.
  """

  def run(string) do
    string
    |> String.graphemes()
    |> Enum.reduce([], fn char, acc ->
      acc = if Enum.count(acc) == 0, do: [char], else: acc
      [head | tail] = acc

      head
      |> String.contains?(char)
      |> case do
        false -> [head <> char | tail]
        true -> ["", head | tail]
      end
    end)
    |> Enum.max_by(&String.length/1)
    |> String.length()
  end
end
