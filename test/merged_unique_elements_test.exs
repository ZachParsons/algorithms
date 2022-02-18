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

  test "build_map/1", %{
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
           } == MUE.count_map(list1)
  end

  # test "success" do
  #   assert [ 0, 2, 4 ] == Recapped.run(list1, list2, n)
  # end
end
