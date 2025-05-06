defmodule ShortestCommonSupersequence.DP do
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
