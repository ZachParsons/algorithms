defmodule Algorithms.Graphs.TSPTest do
  use ExUnit.Case
  alias Algorithms.Graphs.TSP.BB

  test "basic 4-city TSP example" do
    # Expected tour: 0-1-3-2-0 with cost 80
    adj_matrix = [
      [0, 10, 15, 20],
      [10, 0, 35, 25],
      [15, 35, 0, 30],
      [20, 25, 30, 0]
    ]

    {cost, path} = BB.run(adj_matrix)

    assert cost == 80
    assert path == [0, 1, 3, 2, 0]
  end

  test "simple 3-city TSP" do
    # Simple triangle: 0->1 (cost 2), 1->2 (cost 3), 2->0 (cost 1)
    # Optimal tour: 0-2-1-0 with cost 6
    adj_matrix = [
      [0, 2, 1],
      [2, 0, 3],
      [1, 3, 0]
    ]

    {cost, path} = BB.run(adj_matrix)

    assert cost == 6
    # Path should start and end at 0
    assert List.first(path) == 0
    assert List.last(path) == 0
    # Should visit all cities exactly once (plus return to start)
    assert length(path) == 4
  end

  test "single city TSP" do
    adj_matrix = [[0]]

    {cost, path} = BB.run(adj_matrix)

    assert cost == 0
    assert path == [0]
  end

  test "empty matrix" do
    adj_matrix = []

    {cost, path} = BB.run(adj_matrix)

    assert cost == 0
    assert path == []
  end
end
