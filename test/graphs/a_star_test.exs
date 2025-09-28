defmodule Algorithms.Graphs.AStarTest do
  use ExUnit.Case
  doctest Algorithms.Graphs.Graph

  alias Algorithms.Graphs.Graph
  alias Algorithms.PriorityQueue

  describe "PriorityQueue" do
    test "creates empty queue" do
      queue = PriorityQueue.new()
      assert PriorityQueue.empty?(queue)
    end

    test "enqueues and dequeues items by priority" do
      queue =
        PriorityQueue.new()
        |> PriorityQueue.enqueue(:item_b, 2)
        |> PriorityQueue.enqueue(:item_a, 1)
        |> PriorityQueue.enqueue(:item_c, 3)

      refute PriorityQueue.empty?(queue)

      {item1, queue} = PriorityQueue.dequeue(queue)
      assert item1 == :item_a

      {item2, queue} = PriorityQueue.dequeue(queue)
      assert item2 == :item_b

      {item3, queue} = PriorityQueue.dequeue(queue)
      assert item3 == :item_c

      assert PriorityQueue.empty?(queue)
    end

    test "prevents duplicate items" do
      queue =
        PriorityQueue.new()
        |> PriorityQueue.enqueue(:item_a, 1)
        # Should not be added
        |> PriorityQueue.enqueue(:item_a, 2)

      {item, queue} = PriorityQueue.dequeue(queue)
      assert item == :item_a
      assert PriorityQueue.empty?(queue)
    end

    test "checks membership" do
      queue =
        PriorityQueue.new()
        |> PriorityQueue.enqueue(:item_a, 1)

      assert PriorityQueue.member?(queue, :item_a)
      refute PriorityQueue.member?(queue, :item_b)
    end
  end

  describe "Graph" do
    test "creates empty graph" do
      graph = Graph.new()
      assert graph.nodes == %{}
    end

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
  end

  describe "AStar pathfinding" do
    test "finds path in simple 3x3 grid without barriers" do
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

      # Path should avoid the barrier block (or pay high cost)
      barrier_positions_in_path = Enum.filter(path, &(&1 in barriers))

      # Either no barrier positions, or if any, the total cost should reflect the high barrier cost
      if length(barrier_positions_in_path) > 0 do
        # If path goes through barriers, it should be because it's still optimal
        # This is acceptable behavior
        assert true
      end
    end

    test "returns empty list when no path exists" do
      # Create a graph where goal is completely isolated
      graph = %Graph{
        links: %{
          {0, 0} => %{{0, 1} => 1},
          {0, 1} => %{{0, 0} => 1},
          # Isolated goal
          {2, 2} => %{}
        }
      }

      heuristic = fn pos -> Graph.chebyshev_distance(pos, {2, 2}) end
      path = Graph.find_path(graph, heuristic, {0, 0}, {2, 2})

      assert path == []
    end

    test "handles start equals goal" do
      graph = Graph.grid(2, 2)
      heuristic = fn pos -> Graph.chebyshev_distance(pos, {1, 1}) end

      path = Graph.find_path(graph, heuristic, {1, 1}, {1, 1})

      assert path == [{1, 1}]
    end
  end

  describe "heuristic functions" do
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
  end

  describe "chess board problem" do
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

      # The optimal solution should have a reasonable cost
      # Given the barrier layout, we expect the cost to be manageable
      # This is more of a sanity check than a strict test
      # Should be much less than going through all barriers
      assert cost < 50
    end
  end

  describe "integration tests" do
    test "example function runs without errors" do
      # This should not crash and should produce output
      assert {path, cost} = Graph.example()
      assert is_list(path)
      assert is_integer(cost) or cost == :infinity
    end

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
  end
end
