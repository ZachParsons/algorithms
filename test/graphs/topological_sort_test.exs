defmodule Algorithms.Graphs.TopologicalSortTest do
  use ExUnit.Case
  alias Algorithms.Graphs.TopologicalSort

  test "1" do
    courses_count = 2
    prereqs = [[1, 0]]
    expected = true
    res = TopologicalSort.run(courses_count, prereqs)
    assert res == expected
  end

  test "2" do
    courses_count = 2
    prereqs = [[1, 0], [0, 1]]
    expected = false
    res = TopologicalSort.run(courses_count, prereqs)
    assert res == expected
  end
end
