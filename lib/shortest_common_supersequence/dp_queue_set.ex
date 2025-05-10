defmodule ShortestCommonSupersequence.DPQueueSet do
  @moduledoc """
  Dynamic Programming Solution (Using BFS) Pseudocode:
  1. Initialize:
     - Queue with starting state (0,0,[]).
     - Seen_coords set to track visited indexes.
  2. While queue not empty:
     a. Pop state (i,j,acc) from queue.
     b. If state already seen_coords, skip.
     c. Mark state as seen_coords.
     d. Check conditions:
        - If i=len(s1) and j=len(s2) -> found solution, return reversed acc.
        - If i=len(s1) -> must take from s2.
        - If j=len(s2) -> must take from s1.
        - If chars match -> take common char.
        - Else -> try both possibilities (add to queue).
  3. Return shortest found solution.

  Time Complexity: O(m*n) where m, n are lengths of input strings.
  Space Complexity: O(m*n) for seen_coords set and queue.
  """
  # Main entry point that initializes the BFS queue with starting state (0,0,[])
  # and empty seen_coords set. Returns the shortest common supersequence.
  @spec run(s1 :: String.t(), s2 :: String.t()) :: String.t()
  def run(s1, s2) do
    breadth_first_search(
      # Start at beginning of both strings with empty result
      :queue.from_list([{0, 0, []}]),
      # Initialize empty set to track seen_coords states
      MapSet.new(),
      s1,
      s2
    )
  end

  # Core BFS implementation that builds the supersequence.
  # Parameters:
  # - queue: Contains states to explore {i, j, acc} where i, j are indexes in s1, s2.
  # - seen_coords: Set of already visited (i,j) indexes to avoid cycles.
  # - s1, s2: Input strings.
  defp breadth_first_search(queue, seen_coords, s1, s2) do
    # Get next state to explore
    {{:value, {i, j, char_acc}}, queue} = :queue.out(queue)

    # Skip already seen_coords states to avoid redundant work.
    if MapSet.member?(seen_coords, {i, j}) do
      breadth_first_search(queue, seen_coords, s1, s2)
    else
      # Mark current state as seen_coords
      seen_coords = MapSet.put(seen_coords, {i, j})

      cond do
        # Found complete solution when we've used all chars from both strings.
        i == byte_size(s1) and j == byte_size(s2) ->
          char_acc
          |> Enum.reverse()
          |> List.to_string()

        # Must take remaining chars from s2 when s1 is exhausted.
        i == byte_size(s1) ->
          queue = :queue.in({i, j + 1, [String.at(s2, j) | char_acc]}, queue)
          breadth_first_search(queue, seen_coords, s1, s2)

        # Must take remaining chars from s1 when s2 is exhausted.
        j == byte_size(s2) ->
          queue = :queue.in({i + 1, j, [String.at(s1, i) | char_acc]}, queue)
          breadth_first_search(queue, seen_coords, s1, s2)

        # Optimization: When chars match, we can take one and advance both indexes.
        String.at(s1, i) == String.at(s2, j) ->
          queue = :queue.in({i + 1, j + 1, [String.at(s1, i) | char_acc]}, queue)
          breadth_first_search(queue, seen_coords, s1, s2)

        # Try both possibilities: take from s1 or take from s2.
        true ->
          queue = :queue.in({i + 1, j, [String.at(s1, i) | char_acc]}, queue)
          queue = :queue.in({i, j + 1, [String.at(s2, j) | char_acc]}, queue)
          breadth_first_search(queue, seen_coords, s1, s2)
      end
    end
  end
end
