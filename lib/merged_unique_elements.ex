defmodule Algorithms.MergedUniqueElements do
  # Given two lists of sorted integers (positive, negative, and repeating), create a method that returns the first n unique elements from the result of the two lists merged.

  # Example:
  # list1: [ -1, -1, 0, 1, 2, 3, 4, 5 ]
  # list2: [ 1, 3, 5, 7 ]
  # n: 3
  # Output: [ 0, 2, 4 ]

  def run(list1, list2, _unique_int) do
    merge(list1, list2)
  end

  def merge(list1, list2), do: list1 ++ list2

  def count_map(integers_list) do
    integers_list
    |> Enum.reduce(%{}, fn integer, accumulator ->
      if Map.has_key?(accumulator, integer) == false do
        accumulator
        |> Map.put_new(integer, 1)
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

  # pseudocode
  # dumb merge lists
  # sort merged - DONT DO
  # enumerate thru merged
  #   use map to store unique integers
  #   int_value => int_count
  # filter count_map where values == 1
  # take n
  # return
end
