defmodule Algorithms.MergedUniqueElements do
  @moduledoc """

  Given two lists of sorted integers (positive, negative, and repeating), create a method that returns the first n unique elements from the result of the two lists merged.

   Example:
   list1: [ -1, -1, 0, 1, 2, 3, 4, 5 ]
   list2: [ 1, 3, 5, 7 ]
   n: 3
   Output: [ 0, 2, 4 ]

  """

  def run(list1, list2, take) do
    merge(list1, list2)
    |> map_counts()
    |> filter_counts()
    |> take_ints(take)
  end

  def merge(list1, list2), do: list1 ++ list2

  def map_counts(integers) do
    integers
    |> Enum.reduce(%{}, fn integer, accumulator ->
      if Map.has_key?(accumulator, integer) == false do
        Map.put_new(accumulator, integer, 1)
      else
        int_count = Map.get(accumulator, integer)

        Map.put(
          accumulator,
          integer,
          int_count + 1
        )
      end
    end)
  end

  def filter_counts(int_counts) do
    int_counts
    |> Enum.filter(fn {_int, count} -> count == 1 end)
  end

  def take_ints(int_counts, take) do
    int_counts
    |> Enum.take(take)
    |> Enum.map(fn int_count -> elem(int_count, 0) end)
  end

  # pseudocode
  # dumb merge lists
  # sort merged - DONT DO
  # enumerate thru merged
  #   use map to store unique integers
  #     int_value => int_count
  # filter count_map where values == 1
  # take n
end
