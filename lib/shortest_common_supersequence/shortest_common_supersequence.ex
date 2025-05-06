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

  defmodule Naive do
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

  #######################
  defmodule DP do
    @moduledoc """
    Dynamic Programming Solution (Using BFS) Pseudocode:
    1. Initialize:
       - Queue with starting state (0,0,[])
       - Seen set to track visited positions
    2. While queue not empty:
       a. Pop state (i,j,acc) from queue
       b. If state already seen, skip
       c. Mark state as seen
       d. Check conditions:
          - If i=len(s1) and j=len(s2) -> found solution, return reversed acc
          - If i=len(s1) -> must take from s2
          - If j=len(s2) -> must take from s1
          - If chars match -> take common char
          - Else -> try both possibilities (add to queue)
    3. Return shortest found solution

    Time Complexity: O(m*n) where m,n are lengths of input strings
    Space Complexity: O(m*n) for seen set and queue
    """
    # Main entry point that initializes the BFS queue with starting state (0,0,[])
    # and empty seen set. Returns the shortest common supersequence.
    @spec run(s1 :: String.t(), s2 :: String.t()) :: String.t()
    def run(s1, s2) do
      breadth_first_search(
        # Start at beginning of both strings with empty result
        :queue.from_list([{0, 0, []}]),
        # Initialize empty set to track seen states
        MapSet.new(),
        s1,
        s2
      )
    end

    # Core BFS implementation that builds the supersequence
    # Parameters:
    # - queue: Contains states to explore {i, j, acc} where i,j are positions in s1,s2
    # - seen: Set of already visited (i,j) positions to avoid cycles
    # - s1, s2: Input strings
    defp breadth_first_search(queue, seen, s1, s2) do
      # Get next state to explore
      {{:value, {i, j, acc}}, queue} = :queue.out(queue)

      # Skip already seen states to avoid redundant work
      if MapSet.member?(seen, {i, j}) do
        breadth_first_search(queue, seen, s1, s2)
      else
        # Mark current state as seen
        seen = MapSet.put(seen, {i, j})

        cond do
          # Found complete solution when we've used all chars from both strings
          i == byte_size(s1) and j == byte_size(s2) ->
            acc
            |> Enum.reverse()
            |> List.to_string()

          # Must take remaining chars from s2 when s1 is exhausted
          i == byte_size(s1) ->
            queue = :queue.in({i, j + 1, [String.at(s2, j) | acc]}, queue)
            breadth_first_search(queue, seen, s1, s2)

          # Must take remaining chars from s1 when s2 is exhausted
          j == byte_size(s2) ->
            queue = :queue.in({i + 1, j, [String.at(s1, i) | acc]}, queue)
            breadth_first_search(queue, seen, s1, s2)

          # Optimization: When chars match, we can take one and advance both positions
          String.at(s1, i) == String.at(s2, j) ->
            queue = :queue.in({i + 1, j + 1, [String.at(s1, i) | acc]}, queue)
            breadth_first_search(queue, seen, s1, s2)

          # Try both possibilities: take from s1 or take from s2
          true ->
            queue = :queue.in({i + 1, j, [String.at(s1, i) | acc]}, queue)
            queue = :queue.in({i, j + 1, [String.at(s2, j) | acc]}, queue)
            breadth_first_search(queue, seen, s1, s2)
        end
      end
    end
  end
end
