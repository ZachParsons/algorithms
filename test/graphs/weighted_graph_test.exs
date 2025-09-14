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
end
