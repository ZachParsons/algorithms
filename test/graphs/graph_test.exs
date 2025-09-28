defmodule Algorithms.Graphs.GraphTest do
  use ExUnit.Case
  alias Algorithms.Graphs.Graph

  describe "General Graph Operations" do
    test "creates empty graph" do
      graph = Graph.new()
      assert graph.nodes == %{}
    end

    test "adds directed edges" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 5)
        |> Graph.add_edge("A", "C", 3)

      neighbors = Graph.neighbors(graph, "A")
      assert {"C", 3} in neighbors
      assert {"B", 5} in neighbors
      assert length(neighbors) == 2
    end

    test "adds undirected edges" do
      graph =
        Graph.new()
        |> Graph.add_undirected_edge("A", "B", 5)

      assert {"B", 5} in Graph.neighbors(graph, "A")
      assert {"A", 5} in Graph.neighbors(graph, "B")
    end

    test "adds multiple edges" do
      edges = [{"A", "B", 4}, {"A", "C", 2}, {"B", "D", 5}]
      graph = Graph.new() |> Graph.add_edges(edges)

      neighbors_a = Graph.neighbors(graph, "A")
      assert {"C", 2} in neighbors_a
      assert {"B", 4} in neighbors_a
    end

    test "adds multiple undirected edges" do
      edges = [{"A", "B", 4}, {"B", "C", 2}, {"A", "C", 3}]
      graph = Graph.new() |> Graph.add_undirected_edges(edges)

      neighbors_a = Graph.neighbors(graph, "A")
      neighbors_b = Graph.neighbors(graph, "B")

      assert {"B", 4} in neighbors_a
      assert {"C", 3} in neighbors_a
      assert {"A", 4} in neighbors_b
      assert {"C", 2} in neighbors_b
    end

    test "gets all nodes" do
      graph =
        Graph.new()
        |> Graph.add_edges([{"A", "B", 1}, {"B", "C", 1}, {"D", "E", 1}])

      nodes = Graph.all_nodes(graph)
      assert "A" in nodes
      assert "B" in nodes
      assert "C" in nodes
      assert "D" in nodes
      assert "E" in nodes
      assert length(nodes) == 5
    end

    test "allows multiple edges between same nodes" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 1)
        |> Graph.add_edge("A", "B", 2)

      neighbors = Graph.neighbors(graph, "A")
      assert length(neighbors) == 2
      assert {"B", 2} in neighbors
      assert {"B", 1} in neighbors
    end
  end

  describe "Grid Operations" do
    test "creates grid with proper connections" do
      graph = Graph.grid(2, 2)

      # Check that corner position has 3 neighbors
      neighbors = Graph.neighbors(graph, {0, 0})
      assert length(neighbors) == 3
      assert {{0, 1}, 1} in neighbors
      assert {{1, 0}, 1} in neighbors
      assert {{1, 1}, 1} in neighbors

      # Check that center position has 8 neighbors
      neighbors = Graph.neighbors(graph, {1, 1})
      assert length(neighbors) == 8
    end

    test "adds barriers with correct costs" do
      graph = Graph.grid(3, 3)
      barriers = [{1, 1}]
      graph_with_barriers = Graph.with_barriers(graph, barriers, 100)

      # Check that moving to barrier position costs 100
      neighbors = Graph.neighbors(graph_with_barriers, {0, 0})
      barrier_neighbor = Enum.find(neighbors, fn {{x, y}, _cost} -> {x, y} == {1, 1} end)
      assert barrier_neighbor == {{1, 1}, 100}

      # Check that moving from barrier position also costs 100
      neighbors = Graph.neighbors(graph_with_barriers, {1, 1})
      assert Enum.all?(neighbors, fn {_, cost} -> cost == 100 end)
    end

    test "neighbors_map returns map format" do
      graph = Graph.grid(1, 1)
      neighbors_map = Graph.neighbors_map(graph, {0, 0})
      neighbors_list = Graph.neighbors(graph, {0, 0})

      assert is_map(neighbors_map)
      assert is_list(neighbors_list)
      assert map_size(neighbors_map) == length(neighbors_list)
    end
  end

  describe "A* Algorithm" do
    test "finds path in simple grid without barriers" do
      graph = Graph.grid(2, 2)
      heuristic = fn pos -> Graph.chebyshev_distance(pos, {2, 2}) end

      path = Graph.find_path(graph, heuristic, {0, 0}, {2, 2})

      assert length(path) > 0
      assert List.first(path) == {0, 0}
      assert List.last(path) == {2, 2}
    end

    test "finds path around barriers" do
      graph = Graph.grid(4, 4)
      # 2x2 barrier block
      barriers = [{1, 1}, {1, 2}, {2, 1}, {2, 2}]
      graph_with_barriers = Graph.with_barriers(graph, barriers, 100)

      heuristic = fn pos -> Graph.chebyshev_distance(pos, {3, 3}) end
      path = Graph.find_path(graph_with_barriers, heuristic, {0, 0}, {3, 3})

      assert length(path) > 0
      assert List.first(path) == {0, 0}
      assert List.last(path) == {3, 3}
    end

    test "works with general graphs (non-grid)" do
      graph =
        Graph.new()
        |> Graph.add_edges([
          {"start", "A", 1},
          {"A", "B", 2},
          {"B", "goal", 1},
          {"start", "C", 10},
          {"C", "goal", 1}
        ])

      # Simple heuristic: 0 for goal, 1 for others (essentially Dijkstra)
      heuristic = fn
        "goal" -> 0
        _ -> 1
      end

      path = Graph.find_path(graph, heuristic, "start", "goal")

      assert path == ["start", "A", "B", "goal"]
    end

    test "returns empty list when no path exists" do
      graph =
        Graph.new()
        |> Graph.add_edges([
          {"A", "B", 1},
          # Isolated component
          {"C", "D", 1}
        ])

      heuristic = fn _ -> 0 end
      path = Graph.find_path(graph, heuristic, "A", "C")

      assert path == []
    end

    test "handles start equals goal" do
      graph = Graph.grid(2, 2)
      heuristic = fn pos -> Graph.chebyshev_distance(pos, {1, 1}) end

      path = Graph.find_path(graph, heuristic, {1, 1}, {1, 1})

      assert path == [{1, 1}]
    end
  end

  describe "Heuristic Functions" do
    test "chebyshev distance calculation" do
      assert Graph.chebyshev_distance({0, 0}, {3, 4}) == 4
      assert Graph.chebyshev_distance({1, 1}, {1, 1}) == 0
      assert Graph.chebyshev_distance({0, 0}, {2, 2}) == 2
    end

    test "manhattan distance calculation" do
      assert Graph.manhattan_distance({0, 0}, {3, 4}) == 7
      assert Graph.manhattan_distance({1, 1}, {1, 1}) == 0
      assert Graph.manhattan_distance({0, 0}, {2, 2}) == 4
    end

    test "euclidean distance calculation" do
      distance = Graph.euclidean_distance({0, 0}, {3, 4})
      # 3-4-5 triangle
      assert abs(distance - 5.0) < 0.001

      assert Graph.euclidean_distance({1, 1}, {1, 1}) == 0.0
    end
  end

  describe "Chess Board Problem" do
    test "solves the specific chess board problem" do
      {path, cost} = Graph.solve_chess_board_problem()

      # Should find a valid path
      assert length(path) > 0
      assert List.first(path) == {0, 0}
      assert List.last(path) == {7, 7}

      # Cost should be reasonable (not infinity)
      assert is_integer(cost)
      assert cost > 0

      # Path should be continuous (each step should be adjacent)
      path_pairs = Enum.zip(path, tl(path))

      for {{x1, y1}, {x2, y2}} <- path_pairs do
        dx = abs(x2 - x1)
        dy = abs(y2 - y1)
        # Each step should be at most 1 in each direction (king's move)
        assert dx <= 1 and dy <= 1
        # Should actually move
        assert dx > 0 or dy > 0
      end
    end

    test "chess board problem produces optimal or near-optimal solution" do
      {_path, cost} = Graph.solve_chess_board_problem()

      # Should be much less than going through all barriers
      assert cost < 50
    end
  end

  describe "Utility Functions" do
    test "path cost calculation" do
      graph = Graph.grid(2, 2)
      barriers = [{1, 0}]
      graph_with_barriers = Graph.with_barriers(graph, barriers, 10)

      # Test path that goes through a barrier
      path = [{0, 0}, {1, 0}, {1, 1}]
      cost = Graph.calculate_path_cost(graph_with_barriers, path)

      # Should include the barrier cost
      assert cost >= 10
    end

    test "single node path has zero cost" do
      graph = Graph.grid(2, 2)
      cost = Graph.calculate_path_cost(graph, [{1, 1}])
      assert cost == 0
    end
  end

  describe "Integration Tests" do
    test "example function runs without errors" do
      # This should not crash and should produce output
      assert {path, cost} = Graph.example()
      assert is_list(path)
      assert is_integer(cost) or cost == :infinity
    end

    test "grid and general graph operations work together" do
      # Start with a grid
      graph = Graph.grid(2, 2)

      # Add some non-grid edges
      graph = Graph.add_edge(graph, {0, 0}, "external_node", 5)
      graph = Graph.add_edge(graph, "external_node", {2, 2}, 1)

      # Should be able to find path through mixed graph
      heuristic = fn
        {x, y} -> Graph.chebyshev_distance({x, y}, {2, 2})
        # For non-coordinate nodes
        _ -> 1
      end

      path = Graph.find_path(graph, heuristic, {0, 0}, {2, 2})
      assert length(path) > 0
      assert List.first(path) == {0, 0}
      assert List.last(path) == {2, 2}
    end
  end
end
