defmodule Algorithms.Graphs.Dijkstra do
  alias Algorithms.Graphs.Dijkstra.Tree
  alias Algorithms.Graphs.Dijkstra.Search

  @moduledoc """
  Dijkstra's Algorithm Implementations

  This module provides a unified interface to two different implementations of Dijkstra's algorithm,
  each optimized for different use cases. It acts as a facade that delegates to the appropriate
  specialized implementation.

  ## Available Implementations

  ### 1. Tree Implementation (`Algorithms.Graphs.Dijkstra.Tree`)
  Classic Dijkstra's algorithm that builds a complete shortest path tree from source to all nodes.
  Accessed via `shortest_path_tree/2` and `shortest_path/3`.

  ### 2. Search Implementation (`Algorithms.Graphs.Dijkstra.Search`)
  Path-based approach with early termination, optimized for single source-target queries.
  Accessed via `shortest_path_search/3`.

  ## Algorithm Design Differences

  | Aspect             | Tree                                      | Search                              |
  |--------------------|-------------------------------------------|-------------------------------------|
  | **Algorithm Type** | Classic Dijkstra (tree-building)          | Modified Dijkstra (targeted search) |
  | **Scope**          | Source → **ALL nodes**                    | Source → **SPECIFIC target**        |
  | **Termination**    | When all nodes processed                  | When **target found**               |
  | **Data Structure** | Distance map + previous pointers          | Complete paths in priority queue    |
  | **Use Case**       | Multiple target queries                   | Single target queries               |
  | **Memory Usage**   | O(V)                                      | O(V × P) where P = path length      |
  | **Performance**    | Always explores all reachable             | **Early termination** advantage     |
  | **Graph Format**   | `WeightedGraph` struct with adjacency list| Map with `{cost, neighbor}` tuples  |
  | **Return Value**   | `{:ok, {distance, path}}` or distance map | `{total_cost, complete_path}`       |

  ## When to Use Which Implementation

  **Use Tree (`shortest_path_tree/2`, `shortest_path/3`) when:**
  - You need distances to multiple targets from the same source
  - You're working with the structured `WeightedGraph` format
  - You want the classic academic Dijkstra implementation
  - Memory efficiency is important (O(V) vs O(V×P))
  - Production systems (standard, well-tested approach)
  - Educational purposes (matches academic literature)

  **Use Search (`shortest_path_search/3`) when:**
  - You need a path to a single specific target
  - You want early termination for better performance
  - You're working with simple map-based graphs
  - You need the complete path immediately without reconstruction
  - Coding interviews (easier to implement under pressure)
  - Quick prototyping (faster to implement)

  ## Recommendation Matrix

  | Use Case                        | Recommended Implementation | Reason                            |
  |---------------------------------|----------------------------|-----------------------------------|
  | Single path, sparse graph       | `shortest_path_search/3`   | Early termination advantage       |
  | Multiple paths, same source     | `shortest_path_tree/2`     | Amortized cost benefits           |
  | Memory-constrained environment  | `shortest_path_tree/2`     | O(V) vs O(V×P) memory             |
  | Dense graphs                    | `shortest_path_tree/2`     | Avoids path explosion             |
  | Production systems              | `shortest_path_tree/2`     | Standard, well-tested approach    |
  | Coding interviews               | `shortest_path_search/3`   | Easier to implement under pressure|
  | Educational purposes            | `shortest_path_tree/2`     | Matches academic literature       |
  | Quick prototyping               | `shortest_path_search/3`   | Faster to implement               |
  """

  @doc """
  Builds a shortest path tree from source to all other nodes in the graph.

  ## Examples

      iex> graph = Algorithms.WeightedGraph.new()
      ...> |> Algorithms.WeightedGraph.add_edge("A", "B", 4)
      ...> |> Algorithms.WeightedGraph.add_edge("A", "C", 2)
      iex> Algorithms.Graphs.Dijkstra.shortest_path_tree(graph, "A")
      %{"A" => {0, nil}, "B" => {4, "A"}, "C" => {2, "A"}}
  """
  defdelegate shortest_path_tree(graph, source), to: Tree

  @doc """
  Finds the shortest path between two specific nodes.

  ## Examples

      iex> graph = Algorithms.WeightedGraph.new()
      ...> |> Algorithms.WeightedGraph.add_edge("A", "B", 4)
      ...> |> Algorithms.WeightedGraph.add_edge("A", "C", 2)
      ...> |> Algorithms.WeightedGraph.add_edge("C", "B", 1)
      iex> Algorithms.Graphs.Dijkstra.shortest_path(graph, "A", "B")
      {:ok, {3, ["A", "C", "B"]}}
  """
  defdelegate shortest_path(graph, source, target), to: Tree

  @doc """
  Performs targeted shortest path search from source to specific target.

  ## Examples

      iex> graph = %{:a => [{7, :b}, {9, :c}], :b => [{2, :c}], :c => []}
      iex> Algorithms.Graphs.Dijkstra.shortest_path_search(graph, :a, :c)
      {9, [:a, :c]}
  """
  defdelegate shortest_path_search(graph, start, target), to: Search
end
