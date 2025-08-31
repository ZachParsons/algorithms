defmodule Algorithms.QuicksortTest do
  use ExUnit.Case
  alias Algorithms.Quicksort

  describe "sort/1" do
    test "sorts an empty list" do
      assert Quicksort.sort([]) == []
    end

    test "sorts a single element list" do
      assert Quicksort.sort([42]) == [42]
    end

    test "sorts a list with duplicate elements" do
      assert Quicksort.sort([3, 1, 4, 1, 5, 9, 2, 6, 5]) == [1, 1, 2, 3, 4, 5, 5, 6, 9]
    end

    test "sorts an already sorted list" do
      assert Quicksort.sort([1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5]
    end

    test "sorts a reverse sorted list" do
      assert Quicksort.sort([5, 4, 3, 2, 1]) == [1, 2, 3, 4, 5]
    end

    test "sorts a list with all identical elements" do
      assert Quicksort.sort([7, 7, 7, 7, 7]) == [7, 7, 7, 7, 7]
    end

    test "sorts a random unsorted list" do
      assert Quicksort.sort([3, 6, 8, 10, 1, 2, 1]) == [1, 1, 2, 3, 6, 8, 10]
    end

    test "sorts negative numbers" do
      assert Quicksort.sort([-3, -1, -4, -1, -5]) == [-5, -4, -3, -1, -1]
    end

    test "sorts mixed positive and negative numbers" do
      assert Quicksort.sort([3, -1, 4, -2, 0, 1]) == [-2, -1, 0, 1, 3, 4]
    end

    test "sorts floating point numbers" do
      assert Quicksort.sort([3.14, 2.71, 1.41, 1.73]) == [1.41, 1.73, 2.71, 3.14]
    end
  end

  describe "performance characteristics" do
    test "handles worst case scenario (already sorted)" do
      # This tests that our middle pivot selection handles sorted data better
      sorted_list = Enum.to_list(1..100)
      expected = sorted_list
      assert Quicksort.sort(sorted_list) == expected
    end

    test "handles reverse sorted data" do
      # This tests that our middle pivot selection handles reverse sorted data better
      reverse_sorted = Enum.to_list(100..1//-1)
      expected = Enum.to_list(1..100)
      assert Quicksort.sort(reverse_sorted) == expected
    end
  end

  describe "property-based testing" do
    test "sorting is idempotent" do
      list = [5, 2, 8, 1, 9, 3]
      sorted_once = Quicksort.sort(list)
      sorted_twice = Quicksort.sort(sorted_once)
      assert sorted_once == sorted_twice
    end

    test "sorted list has same length as original" do
      list = [1, 2, 3, 2, 1, 4, 5, 4]
      sorted = Quicksort.sort(list)
      assert length(list) == length(sorted)
    end

    test "sorted list contains all original elements" do
      list = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
      sorted = Quicksort.sort(list)

      # Check that each element in original appears same number of times in sorted
      for element <- Enum.uniq(list) do
        original_count = Enum.count(list, &(&1 == element))
        sorted_count = Enum.count(sorted, &(&1 == element))

        assert original_count == sorted_count,
               "Element #{element} appears #{original_count} times in original but #{sorted_count} times in sorted"
      end
    end

    test "result is actually sorted" do
      list = [9, 3, 7, 1, 5, 2, 8, 4, 6]
      sorted = Quicksort.sort(list)

      # Check that each adjacent pair is in order
      sorted
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.each(fn [a, b] ->
        assert a <= b, "Found #{a} > #{b} in supposedly sorted list #{inspect(sorted)}"
      end)
    end
  end
end
