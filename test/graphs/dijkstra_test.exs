defmodule Algorithms.Graphs.DijkstraTest do
  use ExUnit.Case
  alias Algorithms.WeightedGraph
  alias Algorithms.Graphs.Dijkstra.Tree
  alias Algorithms.Graphs.Dijkstra.Search

  # Test helper functions for creating sample graphs
  # Creates a sample graph for testing and demonstration purposes.
  # Returns a graph with nodes A, B, C, D, E connected with various weighted edges.
  defp sample_graph do
    WeightedGraph.new()
    |> WeightedGraph.add_edges([
      {"A", "B", 4},
      {"A", "C", 2},
      {"B", "C", 1},
      {"B", "D", 5},
      {"C", "D", 8},
      {"C", "E", 10},
      {"D", "E", 2},
      {"D", "F", 6},
      {"E", "F", 3}
    ])
  end

  # Creates a sample undirected graph for testing.
  defp sample_undirected_graph do
    WeightedGraph.new()
    |> WeightedGraph.add_undirected_edges([
      {"A", "B", 4},
      {"A", "C", 2},
      {"B", "C", 1},
      {"B", "D", 5},
      {"C", "D", 8},
      {"C", "E", 10},
      {"D", "E", 2}
    ])
  end

  # Creates a sample graph in the alternative format for testing the shortest_path_search function.
  # This matches the format used in the original Erlang implementation.
  defp sample_graph_alternative do
    %{
      :a => [{7, :b}, {9, :c}, {14, :f}],
      :b => [{7, :a}, {10, :c}, {15, :d}],
      :c => [{10, :b}, {9, :a}, {11, :d}, {2, :f}],
      :d => [{15, :b}, {6, :e}, {11, :c}],
      :e => [{9, :f}, {6, :d}],
      :f => [{14, :a}, {2, :c}, {9, :e}]
    }
  end

  # Helper function to convert traditional graph to alternative format
  defp to_alternative_format(%WeightedGraph{nodes: nodes}) do
    nodes
    |> Enum.into(%{}, fn {node, neighbors} ->
      alt_neighbors = Enum.map(neighbors, fn {neighbor, weight} -> {weight, neighbor} end)
      {node, alt_neighbors}
    end)
  end

  # ===================================================================
  # TREE IMPLEMENTATION TESTS
  # Tests that specifically exercise the Tree-based Dijkstra implementation
  # ===================================================================

  describe "Tree Implementation" do
    test "builds shortest path tree from source to all nodes" do
      graph = sample_graph()
      result = Tree.shortest_path_tree(graph, "A")

      assert result["A"] == {0, nil}
      assert result["B"] == {4, "A"}
      assert result["C"] == {2, "A"}
    end

    test "finds shortest path between two nodes" do
      graph = sample_graph()
      {:ok, {distance, path}} = Tree.shortest_path(graph, "A", "E")

      assert distance == 11
      assert path == ["A", "B", "D", "E"]
    end

    test "handles disconnected graphs" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 1},
          {"C", "D", 1}
        ])

      result = Tree.shortest_path(graph, "A", "C")
      assert result == {:error, :no_path}
    end

    test "handles non-existent nodes" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 1},
          {"Z", "Y", 1}
        ])

      result = Tree.shortest_path(graph, "A", "Z")
      assert result == {:error, :no_path}
    end

    test "handles zero-weight edges" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 0},
          {"B", "C", 5}
        ])

      {:ok, {cost, path}} = Tree.shortest_path(graph, "A", "C")
      assert cost == 5
      assert path == ["A", "B", "C"]
    end

    test "handles self-loops" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "A", 1},
          {"A", "B", 2}
        ])

      result = Tree.shortest_path_tree(graph, "A")
      assert elem(result["A"], 0) == 0
      assert elem(result["B"], 0) == 2
    end

    test "handles multiple edges between same nodes" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 5},
          # Better path
          {"A", "B", 2},
          # Worse path
          {"A", "B", 10}
        ])

      {:ok, {cost, _path}} = Tree.shortest_path(graph, "A", "B")
      assert cost == 2
    end

    test "handles single node graph" do
      single_graph = WeightedGraph.new() |> WeightedGraph.add_edge("A", "A", 0)
      result = Tree.shortest_path_tree(single_graph, "A")
      assert result["A"] == {0, nil}
    end

    test "works with undirected graphs" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_undirected_edge("A", "B", 1)
        |> WeightedGraph.add_undirected_edge("B", "C", 2)
        |> WeightedGraph.add_undirected_edge("A", "C", 4)

      # Direct path A->C costs 4, but A->B->C costs 1+2=3
      {:ok, {cost, path}} = Tree.shortest_path(graph, "A", "C")
      assert cost == 3
      assert path == ["A", "B", "C"]

      # Test bidirectionality
      graph_ud = sample_undirected_graph()
      {:ok, {distance_ab, _}} = Tree.shortest_path(graph_ud, "A", "B")
      {:ok, {distance_ba, _}} = Tree.shortest_path(graph_ud, "B", "A")
      assert distance_ab == distance_ba
    end

    test "comprehensive scenario - finds shortest paths from source to all nodes" do
      # Create a sample graph:
      #     A --4-- B
      #     |       |
      #     2       1
      #     |       |
      #     C --8-- D --2-- E
      #     |               |
      #     10              3
      #     |               |
      #     F ------------- G
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 4},
          {"A", "C", 2},
          {"B", "D", 1},
          {"C", "D", 8},
          {"C", "F", 10},
          {"D", "E", 2},
          {"E", "G", 3},
          {"F", "G", 1}
        ])

      result = Tree.shortest_path_tree(graph, "A")

      # Verify distances
      # A to A: 0
      assert elem(result["A"], 0) == 0
      # A to B: 4 (A->B)
      assert elem(result["B"], 0) == 4
      # A to C: 2 (A->C)
      assert elem(result["C"], 0) == 2
      # A to D: 5 (A->B->D)
      assert elem(result["D"], 0) == 5
      # A to E: 7 (A->B->D->E)
      assert elem(result["E"], 0) == 7
      # A to F: 12 (A->C->F)
      assert elem(result["F"], 0) == 12
      # A to G: 10 (A->B->D->E->G)
      assert elem(result["G"], 0) == 10

      # Verify previous nodes for path reconstruction
      assert elem(result["A"], 1) == nil
      assert elem(result["B"], 1) == "A"
      assert elem(result["C"], 1) == "A"
      assert elem(result["D"], 1) == "B"
      assert elem(result["E"], 1) == "D"
      assert elem(result["F"], 1) == "C"
      assert elem(result["G"], 1) == "E"
    end

    test "handles larger graphs efficiently" do
      # Create a larger graph (star pattern)
      center = "center"

      graph =
        Enum.reduce(1..100, WeightedGraph.new(), fn i, acc ->
          node = "node_#{i}"
          WeightedGraph.add_edge(acc, center, node, i)
        end)

      result = Tree.shortest_path_tree(graph, center)

      # Should find paths to all 101 nodes (center + 100 others)
      assert map_size(result) == 101
      assert elem(result[center], 0) == 0
      assert elem(result["node_50"], 0) == 50
    end

    test "handles dense graphs" do
      # Create a small complete graph
      nodes = ["A", "B", "C", "D"]

      graph =
        Enum.reduce(nodes, WeightedGraph.new(), fn from, acc1 ->
          Enum.reduce(nodes, acc1, fn to, acc2 ->
            if from != to do
              # Use sum of ASCII values as weight for deterministic results
              weight = :binary.first(from) + :binary.first(to)
              WeightedGraph.add_edge(acc2, from, to, weight)
            else
              acc2
            end
          end)
        end)

      result = Tree.shortest_path_tree(graph, "A")

      # Should find paths to all nodes
      assert map_size(result) == 4
      assert elem(result["A"], 0) == 0
    end

    test "shortest path distance is never negative" do
      graph = sample_graph()
      result = Tree.shortest_path_tree(graph, "A")

      for {_node, {distance, _prev}} <- result do
        assert distance == :infinity or distance >= 0
      end
    end

    test "path reconstruction gives valid paths" do
      graph = sample_graph()

      # Test several source-destination pairs
      test_pairs = [
        {"A", "B"},
        {"A", "E"},
        {"B", "F"},
        {"C", "D"}
      ]

      for {source, dest} <- test_pairs do
        case Tree.shortest_path(graph, source, dest) do
          {:ok, {_distance, path}} ->
            # Path should start with source and end with destination
            assert List.first(path) == source
            assert List.last(path) == dest

            # Path should have at least one node
            assert length(path) >= 1

            # Each consecutive pair in path should be connected by an edge
            path
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.each(fn [from, to] ->
              neighbors = WeightedGraph.neighbors(graph, from)

              assert Enum.any?(neighbors, fn {neighbor, _weight} -> neighbor == to end),
                     "No edge from #{from} to #{to} in path #{inspect(path)}"
            end)

          {:error, :no_path} ->
            # This is also valid for disconnected graphs
            :ok
        end
      end
    end

    test "triangle inequality holds" do
      graph = sample_graph()

      # For any three nodes A, B, C: distance(A,C) <= distance(A,B) + distance(B,C)
      nodes = ["A", "B", "C", "D", "E"]

      for a <- nodes, b <- nodes, c <- nodes, a != b and b != c and a != c do
        case {Tree.shortest_path(graph, a, b), Tree.shortest_path(graph, b, c),
              Tree.shortest_path(graph, a, c)} do
          {{:ok, {dist_ab, _}}, {:ok, {dist_bc, _}}, {:ok, {dist_ac, _}}} ->
            assert dist_ac <= dist_ab + dist_bc,
                   "Triangle inequality violated: #{a}->#{c} (#{dist_ac}) > #{a}->#{b} (#{dist_ab}) + #{b}->#{c} (#{dist_bc})"

          _ ->
            # Skip if any path doesn't exist
            :ok
        end
      end
    end

    test "validates Tree implementation using NDT format inputs" do
      # Test case 1: Linear network delay scenario
      times_1 = [
        %{source: 2, target: 1, weight: 1},
        %{source: 2, target: 3, weight: 1},
        %{source: 3, target: 4, weight: 1}
      ]

      n_1 = 4
      k_1 = 2

      # Use helper to solve with Tree implementation
      result_1 = solve_ndt_with_tree(times_1, n_1, k_1)
      assert result_1 == 2

      # Verify the underlying Tree shortest_path_tree works correctly
      graph_1 = times_to_weighted_graph(times_1, n_1)
      distances_1 = Tree.shortest_path_tree(graph_1, k_1)

      # Check individual distances from source node 2
      # Source to itself
      assert elem(distances_1[2], 0) == 0
      # 2->1: direct edge weight 1
      assert elem(distances_1[1], 0) == 1
      # 2->3: direct edge weight 1
      assert elem(distances_1[3], 0) == 1
      # 2->3->4: path weight 1+1=2
      assert elem(distances_1[4], 0) == 2

      # Test case 2: Simple two-node scenario
      times_2 = [%{source: 1, target: 2, weight: 1}]
      n_2 = 2
      k_2 = 1

      result_2 = solve_ndt_with_tree(times_2, n_2, k_2)
      assert result_2 == 1

      # Test case 3: Unreachable node scenario
      times_3 = [%{source: 1, target: 2, weight: 1}]
      n_3 = 2
      # Starting from node 2, but node 1 is unreachable
      k_3 = 2

      result_3 = solve_ndt_with_tree(times_3, n_3, k_3)
      assert result_3 == -1
    end
  end

  # ===================================================================
  # SEARCH IMPLEMENTATION TESTS
  # Tests that specifically exercise the Search-based Dijkstra implementation
  # ===================================================================

  describe "Search Implementation" do
    test "shortest_path_search with simple graph" do
      # Simple test case: A -> B -> C
      graph = %{
        :a => [{5, :b}, {10, :c}],
        :b => [{2, :c}],
        :c => []
      }

      {cost, path} = Search.shortest_path_search(graph, :a, :c)
      # Best path should be A -> B -> C = 5 + 2 = 7 (better than direct A -> C = 10)
      assert cost == 7
      assert path == [:a, :b, :c]
    end

    test "shortest_path_search with no path" do
      graph = %{
        :a => [{1, :b}],
        :b => [],
        :c => [{1, :d}],
        :d => []
      }

      {cost, path} = Search.shortest_path_search(graph, :a, :c)
      assert cost == 0
      assert path == []
    end

    test "shortest_path_search to same node" do
      graph = %{:a => [{1, :b}], :b => []}

      {cost, path} = Search.shortest_path_search(graph, :a, :a)
      assert cost == 0
      assert path == [:a]
    end

    test "handles disconnected graphs" do
      alt_graph = %{
        :a => [{1, :b}],
        :b => [{1, :a}],
        :c => [{1, :d}],
        :d => [{1, :c}]
      }

      {cost, path} = Search.shortest_path_search(alt_graph, :a, :c)
      assert cost == 0
      assert path == []
    end

    test "handles non-existent nodes" do
      alt_graph = %{:a => [{1, :b}], :b => []}
      {cost, path} = Search.shortest_path_search(alt_graph, :nonexistent, :b)
      assert cost == 0
      assert path == []
    end

    test "handles empty graph" do
      {cost, path} = Search.shortest_path_search(%{}, :a, :b)
      assert cost == 0
      assert path == []
    end

    test "handles graphs with cycles" do
      graph = %{
        :a => [{1, :b}, {4, :c}],
        # Creates cycle a->b->a
        :b => [{1, :c}, {1, :a}],
        :c => [{1, :d}],
        :d => []
      }

      {cost, path} = Search.shortest_path_search(graph, :a, :d)
      # a->b->c->d = 1+1+1 = 3, vs a->c->d = 4+1 = 5
      assert cost == 3
      assert path == [:a, :b, :c, :d]
    end

    test "works with alternative graph format and original Erlang test case" do
      graph = sample_graph_alternative()
      {cost, path} = Search.shortest_path_search(graph, :a, :e)

      assert cost == 20
      assert path == [:a, :c, :f, :e]
    end

    test "works with different node types" do
      # String nodes
      graph = %{
        "A" => [{5, "B"}, {10, "C"}],
        "B" => [{2, "C"}, {3, "D"}],
        "C" => [{1, "D"}],
        "D" => []
      }

      {cost, path} = Search.shortest_path_search(graph, "A", "D")
      # A->B->D = 5+3 = 8, vs A->C->D = 10+1 = 11, vs A->B->C->D = 5+2+1 = 8
      assert cost == 8
      assert path in [["A", "B", "D"], ["A", "B", "C", "D"]]
    end

    test "handles single node graph" do
      {cost, path} = Search.shortest_path_search(%{:a => []}, :a, :a)
      assert cost == 0
      assert path == [:a]
    end
  end

  # ===================================================================
  # IMPLEMENTATION COMPARISON TESTS
  # Tests that compare Tree and Search implementations for consistency
  # ===================================================================

  describe "Implementation Comparison and Validation" do
    test "finds path to adjacent node - both implementations" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 4},
          {"A", "C", 2}
        ])

      # Test Tree implementation
      {:ok, {tree_cost, tree_path}} = Tree.shortest_path(graph, "A", "B")

      # Test Search implementation
      alternative_graph = to_alternative_format(graph)
      {search_cost, search_path} = Search.shortest_path_search(alternative_graph, "A", "B")

      # Cross-validation: both implementations should give same results
      assert tree_cost == search_cost
      assert tree_path == search_path

      # Verify the expected behavior (test one implementation's specific values)
      assert tree_cost == 4
      assert tree_path == ["A", "B"]
    end

    test "finds path to same node - both implementations" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 4}
        ])

      # Test Tree implementation
      {:ok, {tree_cost, tree_path}} = Tree.shortest_path(graph, "A", "A")

      # Test Search implementation
      alternative_graph = to_alternative_format(graph)
      {search_cost, search_path} = Search.shortest_path_search(alternative_graph, "A", "A")

      # Cross-validation: both implementations should give same results
      assert tree_cost == search_cost
      assert tree_path == search_path

      # Verify the expected behavior (test one implementation's specific values)
      assert tree_cost == 0
      assert tree_path == ["A"]
    end

    test "finds shortest path between connected nodes - both implementations" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 4},
          {"A", "C", 2},
          {"B", "C", 1},
          {"B", "D", 5},
          {"C", "D", 8}
        ])

      # Test Tree implementation: A to D: A->B->D = 4+5 = 9, vs A->C->D = 2+8 = 10
      {:ok, {tree_cost, tree_path}} = Tree.shortest_path(graph, "A", "D")

      # Test Search implementation
      alternative_graph = to_alternative_format(graph)
      {search_cost, search_path} = Search.shortest_path_search(alternative_graph, "A", "D")

      # Cross-validation: both implementations should give same results
      assert tree_cost == search_cost
      assert tree_path == search_path

      # Verify the expected behavior (test one implementation's specific values)
      assert tree_cost == 9
      assert tree_path == ["A", "B", "D"]
    end

    test "finds optimal path when multiple routes exist - both implementations" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 4},
          {"A", "C", 2},
          {"B", "C", 1},
          {"B", "D", 5},
          {"C", "D", 8},
          {"C", "E", 10},
          {"D", "E", 2}
        ])

      # Test Tree implementation: A to E: A->C->E = 2+10 = 12, vs A->B->D->E = 4+5+2 = 11
      {:ok, {tree_cost, tree_path}} = Tree.shortest_path(graph, "A", "E")

      # Test Search implementation
      alternative_graph = to_alternative_format(graph)
      {search_cost, search_path} = Search.shortest_path_search(alternative_graph, "A", "E")

      # Cross-validation: both implementations should give same results
      assert tree_cost == search_cost
      assert tree_path == search_path

      # Verify the expected behavior (test one implementation's specific values)
      assert tree_cost == 11
      assert tree_path == ["A", "B", "D", "E"]
    end

    test "handles zero-weight edges - both implementations" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 0},
          {"B", "C", 5}
        ])

      # Test Tree implementation
      {:ok, {tree_cost, tree_path}} = Tree.shortest_path(graph, "A", "C")

      # Test Search implementation
      alternative_graph = to_alternative_format(graph)
      {search_cost, search_path} = Search.shortest_path_search(alternative_graph, "A", "C")

      # Cross-validation: both implementations should give same results
      assert tree_cost == search_cost
      assert tree_path == search_path

      # Verify the expected behavior (test one implementation's specific values)
      assert tree_cost == 5
      assert tree_path == ["A", "B", "C"]
    end

    test "handles multiple edges between same nodes - both implementations" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 5},
          # Better path
          {"A", "B", 2},
          # Worse path
          {"A", "B", 10}
        ])

      # Test Tree implementation
      {:ok, {tree_cost, tree_path}} = Tree.shortest_path(graph, "A", "B")

      # Test Search implementation
      alternative_graph = to_alternative_format(graph)
      {search_cost, search_path} = Search.shortest_path_search(alternative_graph, "A", "B")

      # Cross-validation: both implementations should give same results
      assert tree_cost == search_cost
      assert tree_path == search_path

      # Verify the expected behavior (test one implementation's specific values)
      assert tree_cost == 2
      assert tree_path == ["A", "B"]
    end

    test "works with undirected graphs - both implementations" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_undirected_edges([
          {"A", "B", 1},
          {"B", "C", 2},
          {"A", "C", 4}
        ])

      # Direct path A->C costs 4, but A->B->C costs 1+2=3
      # Test Tree implementation
      {:ok, {tree_cost, tree_path}} = Tree.shortest_path(graph, "A", "C")

      # Test Search implementation
      alternative_graph = to_alternative_format(graph)
      {search_cost, search_path} = Search.shortest_path_search(alternative_graph, "A", "C")

      # Cross-validation: both implementations should give same results
      assert tree_cost == search_cost
      assert tree_path == search_path

      # Verify the expected behavior (test one implementation's specific values)
      assert tree_cost == 3
      assert tree_path == ["A", "B", "C"]
    end

    test "both implementations find equivalent optimal paths" do
      # Create equivalent graphs in both formats
      traditional_graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edges([
          {"A", "B", 7},
          {"A", "C", 9},
          {"A", "F", 14},
          {"B", "A", 7},
          {"B", "C", 10},
          {"B", "D", 15},
          {"C", "A", 9},
          {"C", "B", 10},
          {"C", "D", 11},
          {"C", "F", 2},
          {"D", "B", 15},
          {"D", "C", 11},
          {"D", "E", 6},
          {"E", "D", 6},
          {"E", "F", 9},
          {"F", "A", 14},
          {"F", "C", 2},
          {"F", "E", 9}
        ])

      alternative_graph = %{
        "A" => [{7, "B"}, {9, "C"}, {14, "F"}],
        "B" => [{7, "A"}, {10, "C"}, {15, "D"}],
        "C" => [{9, "A"}, {10, "B"}, {11, "D"}, {2, "F"}],
        "D" => [{15, "B"}, {11, "C"}, {6, "E"}],
        "E" => [{6, "D"}, {9, "F"}],
        "F" => [{14, "A"}, {2, "C"}, {9, "E"}]
      }

      # Test several paths
      test_pairs = [
        {"A", "E"},
        {"A", "D"},
        {"B", "F"},
        {"C", "E"}
      ]

      for {source, dest} <- test_pairs do
        {:ok, {traditional_cost, _traditional_path}} =
          Tree.shortest_path(traditional_graph, source, dest)

        {alternative_cost, _alternative_path} =
          Search.shortest_path_search(alternative_graph, source, dest)

        assert traditional_cost == alternative_cost,
               "Cost mismatch for #{source}->#{dest}: traditional=#{traditional_cost}, alternative=#{alternative_cost}"
      end
    end

    test "Tree implementation validates correctly using translation functions" do
      # Test multiple NDT scenarios using the translation functions to validate Tree implementation
      test_cases = [
        # Case 1: Linear network delay
        {
          [
            %{source: 2, target: 1, weight: 1},
            %{source: 2, target: 3, weight: 1},
            %{source: 3, target: 4, weight: 1}
          ],
          4,
          2,
          2
        },
        # Case 2: Simple two-node
        {
          [%{source: 1, target: 2, weight: 1}],
          2,
          1,
          1
        },
        # Case 3: Unreachable scenario
        {
          [%{source: 1, target: 2, weight: 1}],
          2,
          2,
          -1
        },
        # Case 4: More complex network
        {
          [
            %{source: 1, target: 2, weight: 1},
            %{source: 1, target: 3, weight: 4},
            %{source: 2, target: 3, weight: 2},
            %{source: 3, target: 4, weight: 1}
          ],
          4,
          1,
          4
        }
      ]

      for {times, n, k, expected} <- test_cases do
        # Test using our helper function (Tree implementation with translation)
        tree_result = solve_ndt_with_tree(times, n, k)

        # Validate that Tree implementation produces expected result
        assert tree_result == expected,
               "Tree result mismatch for case #{inspect({times, n, k})}: got #{tree_result}, expected #{expected}"

        # Additional validation: verify the underlying shortest_path_tree works correctly
        graph = times_to_weighted_graph(times, n)
        distances = Tree.shortest_path_tree(graph, k)
        calculated_delay = calculate_max_delay_from_tree(distances, n)

        # Ensure our helper components work consistently
        assert calculated_delay == tree_result,
               "Helper component mismatch for case #{inspect({times, n, k})}: calculated=#{calculated_delay}, tree=#{tree_result}"
      end
    end
  end

  describe "Network Delay Time Problem" do
    test "network delay time using Tree implementation helpers" do
      # Example 1: times = [[2,1,1],[2,3,1],[3,4,1]], n = 4, k = 2
      # Expected: 2 (max time for signal to reach all nodes)
      times = [
        %{source: 2, target: 1, weight: 1},
        %{source: 2, target: 3, weight: 1},
        %{source: 3, target: 4, weight: 1}
      ]

      n = 4
      k = 2
      assert 2 = solve_ndt_with_tree(times, n, k)

      # Example 2: times = [[1,2,1]], n = 2, k = 1
      # Expected: 1 (signal takes 1 time unit to reach node 2)
      times = [%{source: 1, target: 2, weight: 1}]
      n = 2
      k = 1
      assert 1 = solve_ndt_with_tree(times, n, k)

      # Example 3: times = [[1,2,1]], n = 2, k = 2
      # Expected: -1 (node 2 cannot reach node 1, so not all nodes receive signal)
      times = [%{source: 1, target: 2, weight: 1}]
      n = 2
      k = 2
      assert -1 = solve_ndt_with_tree(times, n, k)
    end
  end

  # Helper functions for NDT format conversion (moved from network_delay_time.ex)
  # These functions allow testing Tree implementation with NDT-format inputs

  # Convert NDT times format to WeightedGraph for Tree implementation testing
  defp times_to_weighted_graph(times, n) do
    # Start with empty graph
    base_graph = WeightedGraph.new()

    # Ensure all nodes 1..n exist in the graph by adding them
    # (WeightedGraph automatically includes nodes when edges are added)
    graph_with_all_nodes =
      1..n
      |> Enum.reduce(base_graph, fn node, acc ->
        # Add a self-loop with weight 0 to ensure node exists in graph
        # This will be ignored during shortest path calculation since we start from source
        if node not in WeightedGraph.all_nodes(acc) do
          WeightedGraph.add_edge(acc, node, node, 0)
        else
          acc
        end
      end)

    # Add all edges from times
    Enum.reduce(times, graph_with_all_nodes, fn %{source: from, target: to, weight: time}, acc ->
      WeightedGraph.add_edge(acc, from, to, time)
    end)
  end

  # Calculate maximum delay from Tree.shortest_path_tree result for NDT validation
  defp calculate_max_delay_from_tree(distances, n) do
    # Get distances to all nodes 1..n
    node_distances =
      1..n
      |> Enum.map(fn node ->
        case Map.get(distances, node) do
          {distance, _prev} when distance == :infinity -> :infinity
          {distance, _prev} -> distance
          # Node not in distances map
          nil -> :infinity
        end
      end)

    # Check if any node is unreachable
    if Enum.any?(node_distances, &(&1 == :infinity)) do
      -1
    else
      # Return maximum time (when the last node receives the signal)
      Enum.max(node_distances)
    end
  end

  # Helper to solve NDT problem using Tree implementation directly (for validation)
  defp solve_ndt_with_tree(times, n, k) do
    # Transform input to WeightedGraph format
    graph = times_to_weighted_graph(times, n)

    # Use Tree implementation to get distances to all nodes
    distances = Tree.shortest_path_tree(graph, k)

    # Extract and validate results
    calculate_max_delay_from_tree(distances, n)
  end
end
