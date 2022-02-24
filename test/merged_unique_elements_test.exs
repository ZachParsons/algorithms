defmodule Algorithms.MergedUniqueElementsTest do
  use ExUnit.Case
  alias Algorithms.MergedUniqueElements, as: MUE

  setup do
    list1 = [-1, -1, 0, 1, 2, 3, 4, 5]
    list2 = [1, 3, 5, 7]
    n = 3
    [list1: list1, list2: list2, n: n]
  end

  test "merge/2", %{
    list1: list1,
    list2: list2
  } do
    assert [-1, -1, 0, 1, 2, 3, 4, 5, 1, 3, 5, 7] == MUE.merge(list1, list2)
  end

  test "map_counts/1", %{
    list1: list1
  } do
    assert %{
             -1 => 2,
             0 => 1,
             1 => 1,
             2 => 1,
             3 => 1,
             4 => 1,
             5 => 1
           } == MUE.map_counts(list1)
  end

  test "filter_counts/1" do
    int_counts = %{
      2 => 2,
      1 => 3,
      3 => 1
    }

    assert [
             {3, 1}
           ] == MUE.filter_counts(int_counts)
  end

  test "take_ints/2" do
    int_counts = [{1, 3}, {2, 2}]
    assert [1] == MUE.take_ints(int_counts, 1)
  end

  test "run/3", %{
    list1: list1,
    list2: list2,
    n: n
  } do
    assert [0, 2, 4] == MUE.run(list1, list2, n)
  end
end
