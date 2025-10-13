defmodule Algorithms.Collections.SlidingWindowMax do
  @moduledoc """
  Optimized Sliding Window Maximum using proper deque with O(1) operations.

  Handles large inputs efficiently:
  - Window sizes up to 50,000+
  - Array lengths in millions
  - True O(n) time complexity
  - O(k) space complexity

  Mnemonic:
  Store: Deque holds indices, values in tuple array for O(1) access
  Slide: Pop front when index outside window (O(1))
  Shrink: Pop back while values ≤ current (O(1) amortized)
  Add: Push current index to back, front gives window max (O(1))

  ## Implementation Comparison

  This module contains two optimized approaches:

  ### run0/2 - Index-based Deque (Recommended for large inputs)
  - **Data Structure**: Stores indices only, looks up values in tuple
  - **Memory**: O(k) deque + O(n) tuple - more memory efficient
  - **Algorithm**: Explicit 4-step process per element
  - **Code Style**: Verbose but clear separation of concerns
  - **Best For**: Large window sizes (50K+), memory-constrained environments
  - **Advantages**: Lower memory overhead, easier to debug, clearer algorithm structure

  ### run1/2 - Value-Index Tuple Deque (Recommended for typical use)
  - **Data Structure**: Stores {value, index} tuples directly in deque
  - **Memory**: O(k) tuples + O(n) original - higher memory overhead
  - **Algorithm**: Functional pipeline using map_reduce
  - **Code Style**: Concise, idiomatic Elixir
  - **Best For**: Typical window sizes (<10K), functional programming preference
  - **Advantages**: More elegant, fewer function calls, idiomatic Elixir style

  ## Performance Recommendations

  **For large-scale problems (window size 50K+):**
  Use `run0/2` - better memory efficiency and scalability

  **For typical applications (window size <10K):**
  Use `run1/2` - more elegant and idiomatic Elixir code

  Both achieve O(n) time complexity with proper deque operations.
  """

  def run0(nums, window_size) when window_size <= 0 or nums == [], do: []

  def run0(nums, window_size) when window_size >= length(nums) do
    [Enum.max(nums)]
  end

  def run0(nums, window_size) do
    # Convert to tuple for O(1) access
    nums_tuple = List.to_tuple(nums)
    n = tuple_size(nums_tuple)

    # Use :queue for true O(1) deque operations
    {result, _deque} =
      0..(n - 1)
      |> Enum.reduce({[], :queue.new()}, fn index, {result, deque} ->
        current_num = elem(nums_tuple, index)

        # Remove indices outside current window - O(1) amortized
        deque = remove_out_of_window(deque, index, window_size)

        # Remove indices with smaller values - O(1) amortized
        deque = remove_smaller_elements(deque, current_num, nums_tuple)

        # Add current index - O(1)
        deque = :queue.in(index, deque)

        # Add result if window is full - O(1)
        if index >= window_size - 1 do
          {{:value, max_index}, _} = :queue.out(deque)
          max_value = elem(nums_tuple, max_index)
          {[max_value | result], deque}
        else
          {result, deque}
        end
      end)

    Enum.reverse(result)
  end

  # O(1) amortized - each element removed at most once
  defp remove_out_of_window(deque, current_index, window_size) do
    case :queue.peek(deque) do
      {:value, front_index} when front_index <= current_index - window_size ->
        {{:value, _}, new_deque} = :queue.out(deque)
        remove_out_of_window(new_deque, current_index, window_size)

      _ ->
        deque
    end
  end

  # O(1) amortized - each element removed at most once
  defp remove_smaller_elements(deque, current_num, nums_tuple) do
    case :queue.peek_r(deque) do
      {:value, back_index} when elem(nums_tuple, back_index) <= current_num ->
        {{:value, _}, new_deque} = :queue.out_r(deque)
        remove_smaller_elements(new_deque, current_num, nums_tuple)

      _ ->
        deque
    end
  end

  # Alternative solution.
  def run1(nums, k) do
    Enum.with_index(nums)
    |> Enum.map_reduce(:queue.new(), fn {x, i}, q ->
      enqueue(q, x, i)
      |> get_max(i - k)
    end)
    |> elem(0)
    |> Enum.drop(k - 1)
  end

  defp enqueue(q, x, i) do
    case :queue.peek_r(q) do
      {:value, {y, _}} when y <= x ->
        :queue.drop_r(q)
        |> enqueue(x, i)

      _ ->
        :queue.in({x, i}, q)
    end
  end

  defp get_max(q, drop_until) do
    case :queue.peek(q) do
      {:value, {_, j}} when j <= drop_until ->
        :queue.drop(q)
        |> get_max(drop_until)

      {:value, {y, _}} ->
        {y, q}
    end
  end
end
