defmodule Algorithms.Knapsack.DP do
  @moduledoc """
  Dynamic Programming solution for the 0/1 Knapsack Problem.

  This implementation uses the classic DP approach with a 2D table where
  dp[i][w] represents the maximum value achievable using the first i items
  with a knapsack capacity of w.

  ## Algorithm Strategy

  - **Bottom-up approach**: Build solutions from smaller subproblems
  - **Optimal substructure**: Optimal solution contains optimal subsolutions
  - **Overlapping subproblems**: Same subproblems rund multiple times
  - **Memoization**: Store results in a table to avoid recomputation

  ## Time Complexity: O(n * W)
  ## Space Complexity: O(n * W)

  Where n = number of items, W = knapsack capacity

  ## Recurrence Relation

      dp[i][w] = max(
        dp[i-1][w],                        # don't take item i
        dp[i-1][w-weight[i]] + value[i]    # take item i (if it fits)
      )

  ## Example

      items = [
        %{value: 60, weight: 10},
        %{value: 100, weight: 20},
        %{value: 120, weight: 30}
      ]

      DynamicProgramming.run(items, 50)
      # Returns: {220, [1, 2]} - optimal value 220 with items at indices 1,2


  Mnemonic:

  input: list(map)
  intermediate: map(map)
  output: tuple
  
  Base: items array → 2D table dp[item][capacity]
  Initialize: fill table with zeros (base cases)
  Nested loops: for each item i, for each capacity w
    If: item fits capacity
      Max: include (prev[w-weight] + value) vs exclude (prev[w])
    Else: copy previous row value (item doesn't fit)
  Backtrack: trace optimal path through filled table
    If: current == previous → item not selected
    Else: item selected → move diagonally back
  Output: max value + selected indices array
  """

  @doc """
  runs the 0/1 knapsack problem using dynamic programming.

  ## Parameters
  - `items`: List of maps with :value and :weight keys
  - `capacity`: Maximum weight capacity of the knapsack

  ## Returns
  - Tuple {max_value, selected_indices} where selected_indices are sorted
  """
  def run([], _capacity), do: {0, []}
  def run(_items, 0), do: {0, []}

  def run(items, capacity) do
    n = length(items)

    # Create DP table: dp[i][w] = max value with first i items and capacity w
    dp_table = create_dp_table(items, capacity)

    # Extract the maximum value
    max_value = dp_table[n][capacity]

    # Backtrack to find which items were selected
    selected_items = backtrack_solution(dp_table, items, n, capacity)

    {max_value, Enum.sort(selected_items)}
  end

  defp create_dp_table(items, capacity) do
    n = length(items)

    # Initialize DP table with zeros
    dp_table =
      for i <- 0..n, into: %{} do
        {i,
         for w <- 0..capacity, into: %{} do
           {w, 0}
         end}
      end

    # Fill the DP table
    items
    |> Enum.with_index()
    |> Enum.reduce(dp_table, fn {item, item_idx}, acc_table ->
      # DP table is 1-indexed for items
      i = item_idx + 1

      for w <- 0..capacity, reduce: acc_table do
        table ->
          cond do
            w == 0 ->
              # Base case: no capacity
              put_in(table[i][w], 0)

            item.weight > w ->
              # Item doesn't fit, take previous best
              put_in(table[i][w], table[i - 1][w])

            true ->
              # Item fits, choose max of including or excluding
              include_value = table[i - 1][w - item.weight] + item.value
              exclude_value = table[i - 1][w]
              put_in(table[i][w], max(include_value, exclude_value))
          end
      end
    end)
  end

  defp backtrack_solution(dp_table, items, n, capacity) do
    backtrack_recursive(dp_table, items, n, capacity, [])
  end

  defp backtrack_recursive(_dp_table, _items, 0, _capacity, selected), do: selected
  defp backtrack_recursive(_dp_table, _items, _i, 0, selected), do: selected

  defp backtrack_recursive(dp_table, items, i, w, selected) do
    current_value = dp_table[i][w]
    previous_value = dp_table[i - 1][w]

    if current_value == previous_value do
      # Item i-1 was not selected (0-indexed items, 1-indexed DP table)
      backtrack_recursive(dp_table, items, i - 1, w, selected)
    else
      # Item i-1 was selected
      item = Enum.at(items, i - 1)
      item_index = i - 1
      backtrack_recursive(dp_table, items, i - 1, w - item.weight, [item_index | selected])
    end
  end
end
