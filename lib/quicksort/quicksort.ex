defmodule Algorithms.Quicksort do
  @moduledoc """
  Quicksort is a divide-and-conquer algorithm that works by selecting a 'pivot' element
  from the array and partitioning the other elements into two sub-arrays according to
  whether they are less than or greater than the pivot.
  """

  def sort([]), do: []

  def sort([h | t]) do
    {lesser, greater} = Enum.split_with(t, &(&1 < h))
    # {lesser, greater} = partition(t, h, [], [])

    sort(lesser) ++ [h] ++ sort(greater)
  end

  # Partitions a list into two lists: elements less than the pivot and elements greater than or equal to the pivot.
  # defp partition([], _pivot, less, greater),
  #   do: {reverse_list(less, []), reverse_list(greater, [])}

  # defp partition([head | tail], pivot, less, greater) do
  #   if head < pivot do
  #     partition(tail, pivot, [head | less], greater)
  #   else
  #     partition(tail, pivot, less, [head | greater])
  #   end
  # end

  # # Reverses a list without using built-in functions.
  # defp reverse_list([], result), do: result
  # defp reverse_list([head | tail], result), do: reverse_list(tail, [head | result])
end
