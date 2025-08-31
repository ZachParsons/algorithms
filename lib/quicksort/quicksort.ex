defmodule Algorithms.Quicksort do
  @moduledoc """
  Quicksort is a divide-and-conquer algorithm that works by selecting a 'pivot' element
  from the array and partitioning the other elements into two sub-arrays according to
  whether they are less than or greater than the pivot.
  """

  def sort([]), do: []
  def sort([head]), do: [head]

  def sort(list) do
    length = length(list)
    middle_index = div(length, 2)
    {pivot, remaining} = extract_element_at_index(list, middle_index, [], 0)
    {less, greater} = partition(remaining, pivot, [], [])
    sort(less) ++ [pivot] ++ sort(greater)
  end

  # Partitions a list into two lists: elements less than the pivot and elements greater than or equal to the pivot.
  defp partition([], _pivot, less, greater),
    do: {reverse_list(less, []), reverse_list(greater, [])}

  defp partition([head | tail], pivot, less, greater) do
    if head < pivot do
      partition(tail, pivot, [head | less], greater)
    else
      partition(tail, pivot, less, [head | greater])
    end
  end

  # Extracts the element at the specified index and returns it along with the remaining list.
  defp extract_element_at_index([head | tail], 0, acc, _current_index) do
    {head, reverse_and_append(acc, tail)}
  end

  defp extract_element_at_index([head | tail], target_index, acc, current_index) do
    extract_element_at_index(tail, target_index, [head | acc], current_index + 1)
  end

  # Handle case where we've run out of elements - return the last element we saw
  defp extract_element_at_index([], _target_index, [head | tail], _current_index) do
    {head, reverse_list(tail, [])}
  end

  # Reverses the accumulator and appends the remaining list without using built-in functions.
  defp reverse_and_append(acc, remaining) do
    reverse_list(acc, remaining)
  end

  defp reverse_list([], result), do: result
  defp reverse_list([head | tail], result), do: reverse_list(tail, [head | result])
end
