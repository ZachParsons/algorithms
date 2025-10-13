defmodule Algorithms.Graphs.TopologicalSortTest do
  use ExUnit.Case
  alias Algorithms.Graphs.TopologicalSort

  test "1" do
    courses_count = 2
    prereqs = [[1, 0]]
    output = true
    res = TopologicalSort.run(courses_count, prereqs)
    assert res == output
  end

  test "2" do
    courses_count = 2
    prereqs = [[1, 0], [0, 1]]
    output = false
    res = TopologicalSort.run(courses_count, prereqs)
    assert res == output
  end
end
