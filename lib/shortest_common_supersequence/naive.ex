defmodule ShortestCommonSupersequence.Naive do
  @moduledoc """
  Naive Solution Pseudocode:
  1. Convert both input strings to character lists
  2. Use recursive pattern matching to build result:
     - Base cases:
       * When both lists are empty -> return accumulated result
       * When one list is empty -> append remaining chars from other list
     - Recursive cases:
       * When both lists start with same char -> add once and recurse
       * When chars differ -> try both possibilities (taking from either list)
       * When accumulated result shares char with input -> optimize by skipping
  3. Join final character list to create result string

  Time Complexity: O(2^(m+n)) where m,n are lengths of input strings
  Space Complexity: O(m+n) for recursion stack
  """
  # Main entry point that converts strings to character lists and initiates the recursive comparison
  # Returns the final result by joining the accumulated characters
  def run(s1, s2) do
    chars1 = String.graphemes(s1)
    chars2 = String.graphemes(s2)

    compare([], chars1, chars2)
    |> Enum.reverse()
    |> Enum.join()
  end

  # Base case: When all input is processed, we've found a valid supersequence
  def compare([], [], []), do: []

  # Optimization case: When both lists start with the same character,
  # we only need to add it once to our result
  def compare([], [a | t2], [a | t3]), do: compare([a], t2, t3)
  # When starting fresh and lists have different first characters,
  # we need to include both characters
  def compare([], [h2 | t2], [h3 | t3]), do: compare([h2, h3], t2, t3)

  # When we've processed both input lists, return our accumulated result
  def compare(acc, [], []), do: acc

  # When first list is empty, we must take remaining chars from second list
  def compare(acc, [], [h3 | t3]), do: compare([h3 | acc], [], t3)
  # Optimization: If next char in second list matches our last accumulated char,
  # we can skip it since it's already represented
  def compare(acc = [a | _t1], [], [a | t3]), do: compare(acc, [], t3)

  # When second list is empty but first list's char matches accumulator,
  # we can skip it
  def compare(acc = [a | _t1], [a | t2], []), do: compare(acc, t2, [])
  # When second list is non-empty and third list is empty,
  # we must take from second list
  def compare(acc, [h2 | t2], []), do: compare([h2 | acc], t2, [])

  # Optimization: When both remaining lists start with same char,
  # we only need to add it once
  def compare(acc, [a | t2], [a | t3]), do: compare([a | acc], t2, t3)

  # When all lists have same char at front, we can optimize by using
  # the one we already have
  def compare(acc = [a | _t1], [a | t2], [a | t3]), do: compare(acc, t2, t3)
  # When accumulator and first list share a char, we can skip it
  def compare(acc = [a | _t1], [a | t2], chars2), do: compare(acc, t2, chars2)
  # When accumulator and second list share a char, we can skip it
  def compare(acc = [a | _t1], chars1, [a | t3]), do: compare(acc, chars1, t3)

  # Most general case: When no optimizations apply, we must try both possibilities
  # by taking a character from either list
  def compare(acc, [h2 | t2], [h3 | t3]), do: compare([h2, h3 | acc], t2, t3)
end
