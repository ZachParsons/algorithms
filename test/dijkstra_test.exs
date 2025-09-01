defmodule Algorithms.DijkstraTest do
  use ExUnit.Case
  alias Algorithms.Dijkstra
  alias Algorithms.Dijkstra.Graph

  # Test helper functions for creating sample graphs

  # Creates a sample graph for testing and demonstration purposes.
  # Returns a graph with nodes A, B, C, D, E connected with various weighted edges.
  defp sample_graph do
    Graph.new()
    |> Graph.add_edge("A", "B", 4)
    |> Graph.add_edge("A", "C", 2)
    |> Graph.add_edge("B", "C", 1)
    |> Graph.add_edge("B", "D", 5)
    |> Graph.add_edge("C", "D", 8)
    |> Graph.add_edge("C", "E", 10)
    |> Graph.add_edge("D", "E", 2)
    |> Graph.add_edge("D", "F", 6)
    |> Graph.add_edge("E", "F", 3)
  end

  # Creates a sample undirected graph for testing.
  defp sample_undirected_graph do
    Graph.new()
    |> Graph.add_undirected_edge("A", "B", 4)
    |> Graph.add_undirected_edge("A", "C", 2)
    |> Graph.add_undirected_edge("B", "C", 1)
    |> Graph.add_undirected_edge("B", "D", 5)
    |> Graph.add_undirected_edge("C", "D", 8)
    |> Graph.add_undirected_edge("C", "E", 10)
    |> Graph.add_undirected_edge("D", "E", 2)
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
  defp to_alternative_format(%Graph{nodes: nodes}) do
    nodes
    |> Enum.into(%{}, fn {node, neighbors} ->
      alt_neighbors = Enum.map(neighbors, fn {neighbor, weight} -> {weight, neighbor} end)
      {node, alt_neighbors}
    end)
  end

  describe "Graph structure operations" do
    test "creates an empty graph" do
      graph = Graph.new()
      assert graph.nodes == %{}
    end

    test "adds an edge to empty graph" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 5)

      assert graph.nodes == %{"A" => [{"B", 5}]}
    end

    test "adds multiple edges from same node" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 5)
        |> Graph.add_edge("A", "C", 3)

      assert graph.nodes["A"] == [{"C", 3}, {"B", 5}]
    end

    test "rejects negative weights" do
      assert_raise FunctionClauseError, fn ->
        Graph.new()
        |> Graph.add_edge("A", "B", -1)
      end
    end

    test "adds bidirectional edges" do
      graph =
        Graph.new()
        |> Graph.add_undirected_edge("A", "B", 5)

      assert graph.nodes["A"] == [{"B", 5}]
      assert graph.nodes["B"] == [{"A", 5}]
    end

    test "returns neighbors of a node" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 5)
        |> Graph.add_edge("A", "C", 3)

      neighbors = Graph.neighbors(graph, "A")
      assert length(neighbors) == 2
      assert {"B", 5} in neighbors
      assert {"C", 3} in neighbors
    end

    test "returns empty list for node with no neighbors" do
      graph = Graph.new()
      assert Graph.neighbors(graph, "A") == []
    end

    test "returns all nodes in graph" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 5)
        |> Graph.add_edge("B", "C", 3)

      nodes = Graph.all_nodes(graph)
      assert length(nodes) == 3
      assert "A" in nodes
      assert "B" in nodes
      assert "C" in nodes
    end

    test "returns empty list for empty graph" do
      graph = Graph.new()
      assert Graph.all_nodes(graph) == []
    end
  end

  describe "Shortest path algorithms - basic functionality" do
    test "finds path to adjacent node" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 4)
        |> Graph.add_edge("A", "C", 2)

      # Test traditional implementation
      {:ok, {traditional_cost, traditional_path}} = Dijkstra.shortest_path(graph, "A", "B")
      assert traditional_cost == 4
      assert traditional_path == ["A", "B"]

      # Test alternative implementation
      alternative_graph = to_alternative_format(graph)

      {alternative_cost, alternative_path} =
        Dijkstra.shortest_path_search(alternative_graph, "A", "B")

      assert alternative_cost == 4
      assert alternative_path == ["A", "B"]
    end

    test "finds path to same node" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 4)

      # Test traditional implementation
      {:ok, {traditional_cost, traditional_path}} = Dijkstra.shortest_path(graph, "A", "A")
      assert traditional_cost == 0
      assert traditional_path == ["A"]

      # Test alternative implementation
      alternative_graph = to_alternative_format(graph)

      {alternative_cost, alternative_path} =
        Dijkstra.shortest_path_search(alternative_graph, "A", "A")

      assert alternative_cost == 0
      assert alternative_path == ["A"]
    end

    test "finds shortest path between connected nodes" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 4)
        |> Graph.add_edge("A", "C", 2)
        |> Graph.add_edge("B", "C", 1)
        |> Graph.add_edge("B", "D", 5)
        |> Graph.add_edge("C", "D", 8)

      # A to D: A->B->D = 4+5 = 9, vs A->C->D = 2+8 = 10
      # Test traditional implementation
      {:ok, {traditional_cost, traditional_path}} = Dijkstra.shortest_path(graph, "A", "D")
      assert traditional_cost == 9
      assert traditional_path == ["A", "B", "D"]

      # Test alternative implementation
      alternative_graph = to_alternative_format(graph)

      {alternative_cost, alternative_path} =
        Dijkstra.shortest_path_search(alternative_graph, "A", "D")

      assert alternative_cost == 9
      assert alternative_path == ["A", "B", "D"]
    end

    test "finds optimal path when multiple routes exist" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 4)
        |> Graph.add_edge("A", "C", 2)
        |> Graph.add_edge("B", "C", 1)
        |> Graph.add_edge("B", "D", 5)
        |> Graph.add_edge("C", "D", 8)
        |> Graph.add_edge("C", "E", 10)
        |> Graph.add_edge("D", "E", 2)

      # A to E: A->C->E = 2+10 = 12, vs A->B->D->E = 4+5+2 = 11
      # Test traditional implementation
      {:ok, {traditional_cost, traditional_path}} = Dijkstra.shortest_path(graph, "A", "E")
      assert traditional_cost == 11
      assert traditional_path == ["A", "B", "D", "E"]

      # Test alternative implementation
      alternative_graph = to_alternative_format(graph)

      {alternative_cost, alternative_path} =
        Dijkstra.shortest_path_search(alternative_graph, "A", "E")

      assert alternative_cost == 11
      assert alternative_path == ["A", "B", "D", "E"]
    end
  end

  describe "Shortest path algorithms - edge cases" do
    test "handles disconnected graphs" do
      # Traditional implementation
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 1)
        |> Graph.add_edge("C", "D", 1)

      result = Dijkstra.shortest_path(graph, "A", "C")
      assert result == {:error, :no_path}

      # Alternative implementation
      alt_graph = %{
        :a => [{1, :b}],
        :b => [{1, :a}],
        :c => [{1, :d}],
        :d => [{1, :c}]
      }

      {cost, path} = Dijkstra.shortest_path_search(alt_graph, :a, :c)
      assert cost == 0
      assert path == []
    end

    test "handles non-existent nodes" do
      # Traditional implementation - test with node that exists but is disconnected
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 1)
        # Add isolated nodes
        |> Graph.add_edge("Z", "Y", 1)

      result = Dijkstra.shortest_path(graph, "A", "Z")
      assert result == {:error, :no_path}

      # Alternative implementation
      alt_graph = %{:a => [{1, :b}], :b => []}
      {cost, path} = Dijkstra.shortest_path_search(alt_graph, :nonexistent, :b)
      assert cost == 0
      assert path == []
    end

    test "handles zero-weight edges" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 0)
        |> Graph.add_edge("B", "C", 5)

      # Test traditional implementation
      {:ok, {traditional_cost, traditional_path}} = Dijkstra.shortest_path(graph, "A", "C")
      assert traditional_cost == 5
      assert traditional_path == ["A", "B", "C"]

      # Test alternative implementation
      alternative_graph = to_alternative_format(graph)

      {alternative_cost, alternative_path} =
        Dijkstra.shortest_path_search(alternative_graph, "A", "C")

      assert alternative_cost == 5
      assert alternative_path == ["A", "B", "C"]
    end

    test "handles self-loops" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "A", 1)
        |> Graph.add_edge("A", "B", 2)

      # Test traditional implementation
      result = Dijkstra.shortest_path_tree(graph, "A")
      assert elem(result["A"], 0) == 0
      assert elem(result["B"], 0) == 2

      # Test alternative implementation
      alt_graph = to_alternative_format(graph)
      {cost, path} = Dijkstra.shortest_path_search(alt_graph, "A", "A")
      assert cost == 0
      assert path == ["A"]
    end

    test "handles multiple edges between same nodes" do
      graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 5)
        # Better path
        |> Graph.add_edge("A", "B", 2)
        # Worse path
        |> Graph.add_edge("A", "B", 10)

      # Test traditional implementation
      {:ok, {traditional_cost, _traditional_path}} = Dijkstra.shortest_path(graph, "A", "B")
      assert traditional_cost == 2

      # Test alternative implementation
      alternative_graph = to_alternative_format(graph)

      {alternative_cost, _alternative_path} =
        Dijkstra.shortest_path_search(alternative_graph, "A", "B")

      assert alternative_cost == 2
    end

    test "handles single node graph" do
      # Traditional implementation
      single_graph = Graph.new() |> Graph.add_edge("A", "A", 0)
      result = Dijkstra.shortest_path_tree(single_graph, "A")
      assert result["A"] == {0, nil}

      # Alternative implementation
      {cost, path} = Dijkstra.shortest_path_search(%{:a => []}, :a, :a)
      assert cost == 0
      assert path == [:a]
    end

    test "handles empty graph" do
      {cost, path} = Dijkstra.shortest_path_search(%{}, :a, :b)
      assert cost == 0
      assert path == []
    end

    test "handles graphs with cycles" do
      # Alternative implementation test
      graph = %{
        :a => [{1, :b}, {4, :c}],
        # Creates cycle a->b->a
        :b => [{1, :c}, {1, :a}],
        :c => [{1, :d}],
        :d => []
      }

      {cost, path} = Dijkstra.shortest_path_search(graph, :a, :d)
      # a->b->c->d = 1+1+1 = 3, vs a->c->d = 4+1 = 5
      assert cost == 3
      assert path == [:a, :b, :c, :d]
    end
  end

  describe "Shortest path algorithms - undirected graphs" do
    test "works with undirected graphs" do
      graph =
        Graph.new()
        |> Graph.add_undirected_edge("A", "B", 1)
        |> Graph.add_undirected_edge("B", "C", 2)
        |> Graph.add_undirected_edge("A", "C", 4)

      # Direct path A->C costs 4, but A->B->C costs 1+2=3
      # Test traditional implementation
      {:ok, {traditional_cost, traditional_path}} = Dijkstra.shortest_path(graph, "A", "C")
      assert traditional_cost == 3
      assert traditional_path == ["A", "B", "C"]

      # Test alternative implementation
      alternative_graph = to_alternative_format(graph)

      {alternative_cost, alternative_path} =
        Dijkstra.shortest_path_search(alternative_graph, "A", "C")

      assert alternative_cost == 3
      assert alternative_path == ["A", "B", "C"]

      # Test bidirectionality
      graph_ud = sample_undirected_graph()
      {:ok, {distance_ab, _}} = Dijkstra.shortest_path(graph_ud, "A", "B")
      {:ok, {distance_ba, _}} = Dijkstra.shortest_path(graph_ud, "B", "A")
      assert distance_ab == distance_ba
    end
  end

  describe "Shortest path algorithms - comprehensive scenarios" do
    test "finds shortest paths from source to all nodes" do
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
        Graph.new()
        |> Graph.add_edge("A", "B", 4)
        |> Graph.add_edge("A", "C", 2)
        |> Graph.add_edge("B", "D", 1)
        |> Graph.add_edge("C", "D", 8)
        |> Graph.add_edge("C", "F", 10)
        |> Graph.add_edge("D", "E", 2)
        |> Graph.add_edge("E", "G", 3)
        |> Graph.add_edge("F", "G", 1)

      result = Dijkstra.shortest_path_tree(graph, "A")

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

    test "works with alternative graph format and original Erlang test case" do
      graph = sample_graph_alternative()
      {cost, path} = Dijkstra.shortest_path_search(graph, :a, :e)

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

      {cost, path} = Dijkstra.shortest_path_search(graph, "A", "D")
      # A->B->D = 5+3 = 8, vs A->C->D = 10+1 = 11, vs A->B->C->D = 5+2+1 = 8
      assert cost == 8
      assert path in [["A", "B", "D"], ["A", "B", "C", "D"]]
    end
  end

  describe "Implementation comparison and validation" do
    test "both implementations find equivalent optimal paths" do
      # Create equivalent graphs in both formats
      traditional_graph =
        Graph.new()
        |> Graph.add_edge("A", "B", 7)
        |> Graph.add_edge("A", "C", 9)
        |> Graph.add_edge("A", "F", 14)
        |> Graph.add_edge("B", "A", 7)
        |> Graph.add_edge("B", "C", 10)
        |> Graph.add_edge("B", "D", 15)
        |> Graph.add_edge("C", "A", 9)
        |> Graph.add_edge("C", "B", 10)
        |> Graph.add_edge("C", "D", 11)
        |> Graph.add_edge("C", "F", 2)
        |> Graph.add_edge("D", "B", 15)
        |> Graph.add_edge("D", "C", 11)
        |> Graph.add_edge("D", "E", 6)
        |> Graph.add_edge("E", "D", 6)
        |> Graph.add_edge("E", "F", 9)
        |> Graph.add_edge("F", "A", 14)
        |> Graph.add_edge("F", "C", 2)
        |> Graph.add_edge("F", "E", 9)

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
          Dijkstra.shortest_path(traditional_graph, source, dest)

        {alternative_cost, _alternative_path} =
          Dijkstra.shortest_path_search(alternative_graph, source, dest)

        assert traditional_cost == alternative_cost,
               "Cost mismatch for #{source}->#{dest}: traditional=#{traditional_cost}, alternative=#{alternative_cost}"
      end
    end
  end

  describe "Performance characteristics" do
    test "handles larger graphs efficiently" do
      # Create a larger graph (star pattern)
      center = "center"

      graph =
        Enum.reduce(1..100, Graph.new(), fn i, acc ->
          node = "node_#{i}"
          Graph.add_edge(acc, center, node, i)
        end)

      result = Dijkstra.shortest_path_tree(graph, center)

      # Should find paths to all 101 nodes (center + 100 others)
      assert map_size(result) == 101
      assert elem(result[center], 0) == 0
      assert elem(result["node_50"], 0) == 50
    end

    test "handles dense graphs" do
      # Create a small complete graph
      nodes = ["A", "B", "C", "D"]

      graph =
        Enum.reduce(nodes, Graph.new(), fn from, acc1 ->
          Enum.reduce(nodes, acc1, fn to, acc2 ->
            if from != to do
              # Use sum of ASCII values as weight for deterministic results
              weight = :binary.first(from) + :binary.first(to)
              Graph.add_edge(acc2, from, to, weight)
            else
              acc2
            end
          end)
        end)

      result = Dijkstra.shortest_path_tree(graph, "A")

      # Should find paths to all nodes
      assert map_size(result) == 4
      assert elem(result["A"], 0) == 0
    end
  end

  describe "Property-based validation" do
    test "shortest path distance is never negative" do
      graph = sample_graph()
      result = Dijkstra.shortest_path_tree(graph, "A")

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
        case Dijkstra.shortest_path(graph, source, dest) do
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
              neighbors = Graph.neighbors(graph, from)

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
        case {Dijkstra.shortest_path(graph, a, b), Dijkstra.shortest_path(graph, b, c),
              Dijkstra.shortest_path(graph, a, c)} do
          {{:ok, {dist_ab, _}}, {:ok, {dist_bc, _}}, {:ok, {dist_ac, _}}} ->
            assert dist_ac <= dist_ab + dist_bc,
                   "Triangle inequality violated: #{a}->#{c} (#{dist_ac}) > #{a}->#{b} (#{dist_ab}) + #{b}->#{c} (#{dist_bc})"

          _ ->
            # Skip if any path doesn't exist
            :ok
        end
      end
    end
  end
end
