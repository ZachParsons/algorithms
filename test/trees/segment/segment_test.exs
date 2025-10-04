defmodule Algorithms.Trees.SegmentTest do
  use ExUnit.Case
  alias Algorithms.Trees.Segment

  # Functional implementation tests
  test "functional segment tree basic operations" do
    # Initialize with [1, 3, 5]
    tree = Segment.init([1, 3, 5])

    # Test initial sum_range: 1 + 3 + 5 = 9
    assert Segment.sum_range(tree, 0, 2) == 9

    # Update index 1 to value 2: [1, 3, 5] -> [1, 2, 5]
    updated_tree = Segment.update(tree, 1, 2)

    # Test sum_range after update: 1 + 2 + 5 = 8
    assert Segment.sum_range(updated_tree, 0, 2) == 8

    # Original tree should be unchanged (immutability)
    assert Segment.sum_range(tree, 0, 2) == 9
  end

  test "functional segment tree various range queries" do
    # Initialize with a larger array
    tree = Segment.init([1, 3, 5, 7, 9, 11])

    # Test different ranges
    # Single element
    assert Segment.sum_range(tree, 0, 0) == 1
    # 3 + 5 + 7 = 15
    assert Segment.sum_range(tree, 1, 3) == 15
    # 5 + 7 + 9 + 11 = 32
    assert Segment.sum_range(tree, 2, 5) == 32
    # Sum of all elements
    assert Segment.sum_range(tree, 0, 5) == 36

    # Update and test
    # [1, 3, 5, 7, 9, 11] -> [1, 3, 10, 7, 9, 11]
    updated_tree = Segment.update(tree, 2, 10)
    # 3 + 10 + 7 = 20
    assert Segment.sum_range(updated_tree, 1, 3) == 20
    # 1 + 3 + 10 + 7 + 9 + 11 = 41
    assert Segment.sum_range(updated_tree, 0, 5) == 41

    # Original tree should be unchanged
    assert Segment.sum_range(tree, 1, 3) == 15
    assert Segment.sum_range(tree, 0, 5) == 36
  end

  test "functional segment tree edge cases" do
    # Single element array
    tree = Segment.init([42])
    assert Segment.sum_range(tree, 0, 0) == 42

    updated_tree = Segment.update(tree, 0, 100)
    assert Segment.sum_range(updated_tree, 0, 0) == 100

    # Original unchanged
    assert Segment.sum_range(tree, 0, 0) == 42

    # Two element array
    tree2 = Segment.init([10, 20])
    assert Segment.sum_range(tree2, 0, 1) == 30
    assert Segment.sum_range(tree2, 0, 0) == 10
    assert Segment.sum_range(tree2, 1, 1) == 20

    updated_tree2 = Segment.update(tree2, 0, 15)
    assert Segment.sum_range(updated_tree2, 0, 1) == 35

    # Original unchanged
    assert Segment.sum_range(tree2, 0, 1) == 30
  end

  test "functional segment tree empty array" do
    # Empty array
    tree = Segment.init([])
    assert Segment.sum_range(tree, 0, 0) == 0
  end

  test "functional segment tree immutability chain" do
    # Test chaining operations while maintaining immutability
    tree1 = Segment.init([1, 2, 3, 4])
    # [10, 2, 3, 4]
    tree2 = Segment.update(tree1, 0, 10)
    # [10, 20, 3, 4]
    tree3 = Segment.update(tree2, 1, 20)
    # [10, 20, 30, 4]
    tree4 = Segment.update(tree3, 2, 30)

    # Each tree should maintain its own state
    # 1+2+3+4
    assert Segment.sum_range(tree1, 0, 3) == 10
    # 10+2+3+4
    assert Segment.sum_range(tree2, 0, 3) == 19
    # 10+20+3+4
    assert Segment.sum_range(tree3, 0, 3) == 37
    # 10+20+30+4
    assert Segment.sum_range(tree4, 0, 3) == 64
  end
end
