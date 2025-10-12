defmodule Algorithms.Collections.SlidingWindowMax do
  @moduledoc """
  Sliding Window Maximum algorithm using a deque approach.

  Given an array of integers and a window size k, returns an array containing
  the maximum value in each sliding window of size k.

  Time Complexity: O(n)
  Space Complexity: O(k)
  """

  def run(nums, window_size) when window_size <= 0 or nums == [], do: []

  def run(nums, window_size) when window_size >= length(nums) do
    [Enum.max(nums)]
  end

  def run(nums, window_size) do
    # Use a deque to store indices of array elements
    # The deque will maintain elements in decreasing order of their values
    indexed_nums = Enum.with_index(nums)

    {result, _deque} =
      indexed_nums
      |> Enum.reduce({[], []}, fn {num, index}, {result, deque} ->
        # Remove indices that are out of current window
        deque = remove_out_of_window(deque, index, window_size)

        # Remove indices whose corresponding values are smaller than current num
        # since they can never be maximum while current num is in window
        deque = remove_smaller_elements(deque, num, nums)

        # Add current index to deque
        deque = deque ++ [index]

        # If we have processed at least window_size elements, add max to result
        if index >= window_size - 1 do
          max_index = hd(deque)
          max_value = Enum.at(nums, max_index)
          {result ++ [max_value], deque}
        else
          {result, deque}
        end
      end)

    result
  end

  # Remove indices that are outside the current window
  defp remove_out_of_window(deque, current_index, window_size) do
    Enum.drop_while(deque, fn index ->
      index <= current_index - window_size
    end)
  end

  # Remove indices whose values are smaller than current number
  defp remove_smaller_elements(deque, current_num, nums) do
    Enum.reverse(deque)
    |> Enum.drop_while(fn index ->
      Enum.at(nums, index) <= current_num
    end)
    |> Enum.reverse()
  end
end
