defmodule Algorithms.Knapsack.BranchAndBound do
  @moduledoc """
  Branch and Bound solution for the 0/1 Knapsack Problem.

  This implementation exemplifies the branch and bound algorithmic strategy through
  four key components:

  ## 1. Branching - Systematic Solution Space Exploration

  Creates a binary decision tree where each node represents a choice:
  - **Include current item**: Add item to knapsack, reduce remaining capacity
  - **Exclude current item**: Skip item, maintain current capacity

  For each item, the algorithm explores both branches recursively, building
  a complete search tree of all possible item combinations.

  ## 2. Bounding - Upper Bound Calculation

  Uses fractional knapsack to calculate optimistic upper bounds:
  - Sort remaining items by value/weight ratio (descending)
  - Take whole items until capacity is exceeded
  - Take fraction of next item to fill remaining capacity
  - This gives the theoretical maximum value achievable from current state

  The fractional bound is always ≥ the actual optimal value, making it
  a valid upper bound for pruning decisions.

  ## 3. Pruning - Eliminating Unpromising Branches

  Aggressive branch elimination using the bounding function:
  - If `upper_bound ≤ current_best_value`, skip entire subtree
  - Also prunes when current item exceeds remaining capacity
  - This dramatically reduces the search space from O(2^n) to much smaller

  ## 4. Optimality Guarantee

  Unlike greedy algorithms, branch and bound:
  - Explores all promising branches (complete search)
  - Guarantees finding the true optimal solution
  - Uses intelligent pruning to avoid exhaustive enumeration

  ## Example

      items = [
        %{value: 60, weight: 10},
        %{value: 100, weight: 20},
        %{value: 120, weight: 30}
      ]

      Knapsack.run(items, 50)
      # Returns: {220, [1, 2]} - optimal value 220 with items at indices 1,2

  ## Time Complexity

  - **Worst case**: O(2^n) - when no pruning is possible
  - **Average case**: Much better due to aggressive pruning
  - **Best case**: O(n log n) - when bounds eliminate most branches

  The fractional knapsack bound is particularly effective because it's:
  - **Fast to compute**: O(n log n) for sorting
  - **Tight bound**: Close to actual optimal value
  - **Easy to implement**: Standard greedy fractional knapsack
  """
  def run(_items = [], _capacity), do: {0, []}
  def run(_items, _capacity = 0), do: {0, []}

  def run(items, capacity) do
    # Add indices to items
    indexed_items = Enum.with_index(items)

    # Initialize the branch and bound search
    initial_state = %{
      best_value: 0,
      best_solution: [],
      remaining_capacity: capacity,
      current_value: 0,
      current_solution: []
    }

    # Start recursive search
    final_state = run_recursive(indexed_items, 0, initial_state)

    # Return result in original order
    {final_state.best_value, Enum.sort(final_state.best_solution)}
  end

  defp run_recursive(items, current_idx, state) when current_idx >= length(items) do
    # Update best solution if current is better
    if state.current_value > state.best_value do
      %{state | best_value: state.current_value, best_solution: state.current_solution}
    else
      state
    end
  end

  defp run_recursive(items, current_idx, state) do
    {current_item, idx} = Enum.at(items, current_idx)
    bound = calculate_bound(items, current_idx, state.remaining_capacity, state.current_value)

    # Only explore branch if it could lead to better solution
    if bound > state.best_value and state.remaining_capacity >= current_item.weight do
      # Try including current item
      include_state = %{
        state
        | remaining_capacity: state.remaining_capacity - current_item.weight,
          current_value: state.current_value + current_item.value,
          current_solution: [idx | state.current_solution]
      }

      # Recursively explore both branches and take best result
      include_result = run_recursive(items, current_idx + 1, include_state)
      exclude_result = run_recursive(items, current_idx + 1, state)

      if include_result.best_value > exclude_result.best_value do
        include_result
      else
        exclude_result
      end
    else
      # Skip this item and continue with next
      run_recursive(items, current_idx + 1, state)
    end
  end

  # Calculate upper bound for remaining items using fractional knapsack
  defp calculate_bound(items, start_idx, remaining_capacity, current_value) do
    items
    |> Enum.drop(start_idx)
    |> Enum.sort_by(fn {item, _idx} -> item.value / item.weight end, :desc)
    |> Enum.reduce_while({current_value, remaining_capacity}, fn {item, _idx},
                                                                 {value, capacity} ->
      cond do
        capacity <= 0 ->
          {:halt, {value, capacity}}

        item.weight > capacity ->
          # Take fraction of item
          fraction = capacity / item.weight
          {:halt, {value + item.value * fraction, capacity}}

        true ->
          # Take whole item
          {:cont, {value + item.value, capacity - item.weight}}
      end
    end)
    |> elem(0)
  end
end
