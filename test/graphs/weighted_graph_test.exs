defmodule Algorithms.WeightedGraphTest do
  use ExUnit.Case
  alias Algorithms.WeightedGraph

  describe "Graph structure operations" do
    test "creates an empty graph" do
      graph = WeightedGraph.new()
      assert graph.nodes == %{}
    end

    test "adds an edge to empty graph" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edge("A", "B", 5)

      assert graph.nodes == %{"A" => [{"B", 5}]}
    end

    test "adds multiple edges from same node" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edge("A", "B", 5)
        |> WeightedGraph.add_edge("A", "C", 3)

      assert graph.nodes["A"] == [{"C", 3}, {"B", 5}]
    end

    test "rejects negative weights" do
      assert_raise FunctionClauseError, fn ->
        WeightedGraph.new()
        |> WeightedGraph.add_edge("A", "B", -1)
      end
    end

    test "adds bidirectional edges" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_undirected_edge("A", "B", 5)

      assert graph.nodes["A"] == [{"B", 5}]
      assert graph.nodes["B"] == [{"A", 5}]
    end

    test "returns neighbors of a node" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edge("A", "B", 5)
        |> WeightedGraph.add_edge("A", "C", 3)

      neighbors = WeightedGraph.neighbors(graph, "A")
      assert length(neighbors) == 2
      assert {"B", 5} in neighbors
      assert {"C", 3} in neighbors
    end

    test "returns empty list for node with no neighbors" do
      graph = WeightedGraph.new()
      assert WeightedGraph.neighbors(graph, "A") == []
    end

    test "returns all nodes in graph" do
      graph =
        WeightedGraph.new()
        |> WeightedGraph.add_edge("A", "B", 5)
        |> WeightedGraph.add_edge("B", "C", 3)

      nodes = WeightedGraph.all_nodes(graph)
      assert length(nodes) == 3
      assert "A" in nodes
      assert "B" in nodes
      assert "C" in nodes
    end

    test "returns empty list for empty graph" do
      graph = WeightedGraph.new()
      assert WeightedGraph.all_nodes(graph) == []
    end
  end

  describe "add_edges/2" do
    test "adds multiple directed edges at once" do
      edges = [
        {"A", "B", 4},
        {"A", "C", 2},
        {"B", "D", 5},
        {"C", "D", 8}
      ]

      graph = WeightedGraph.new() |> WeightedGraph.add_edges(edges)

      # Check that all edges were added
      neighbors_a = WeightedGraph.neighbors(graph, "A")
      assert {"B", 4} in neighbors_a
      assert {"C", 2} in neighbors_a

      neighbors_b = WeightedGraph.neighbors(graph, "B")
      assert {"D", 5} in neighbors_b

      neighbors_c = WeightedGraph.neighbors(graph, "C")
      assert {"D", 8} in neighbors_c
    end

    test "works with empty edge list" do
      graph = WeightedGraph.new() |> WeightedGraph.add_edges([])
      assert WeightedGraph.all_nodes(graph) == []
    end

    test "equivalent to chaining add_edge calls" do
      edges = [{"A", "B", 1}, {"B", "C", 2}, {"A", "C", 3}]

      # Using add_edges
      graph1 = WeightedGraph.new() |> WeightedGraph.add_edges(edges)

      # Using chained add_edge calls
      graph2 =
        WeightedGraph.new()
        |> WeightedGraph.add_edge("A", "B", 1)
        |> WeightedGraph.add_edge("B", "C", 2)
        |> WeightedGraph.add_edge("A", "C", 3)

      # Should produce identical graphs
      assert graph1 == graph2
    end
  end

  describe "add_undirected_edges/2" do
    test "adds multiple undirected edges at once" do
      edges = [
        {"A", "B", 4},
        {"B", "C", 2},
        {"A", "C", 3}
      ]

      graph = WeightedGraph.new() |> WeightedGraph.add_undirected_edges(edges)

      # Check bidirectional connections
      neighbors_a = WeightedGraph.neighbors(graph, "A")
      assert {"B", 4} in neighbors_a
      assert {"C", 3} in neighbors_a

      neighbors_b = WeightedGraph.neighbors(graph, "B")
      assert {"A", 4} in neighbors_b
      assert {"C", 2} in neighbors_b

      neighbors_c = WeightedGraph.neighbors(graph, "C")
      assert {"A", 3} in neighbors_c
      assert {"B", 2} in neighbors_c
    end

    test "works with empty edge list" do
      graph = WeightedGraph.new() |> WeightedGraph.add_undirected_edges([])
      assert WeightedGraph.all_nodes(graph) == []
    end

    test "equivalent to chaining add_undirected_edge calls" do
      edges = [{"A", "B", 1}, {"B", "C", 2}]

      # Using add_undirected_edges
      graph1 = WeightedGraph.new() |> WeightedGraph.add_undirected_edges(edges)

      # Using chained add_undirected_edge calls
      graph2 =
        WeightedGraph.new()
        |> WeightedGraph.add_undirected_edge("A", "B", 1)
        |> WeightedGraph.add_undirected_edge("B", "C", 2)

      # Should produce identical graphs
      assert graph1 == graph2
    end
  end
end
