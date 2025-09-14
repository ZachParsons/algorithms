defmodule Algorithms.Dijkstra do
  alias Algorithms.Graph

  @moduledoc """
  Two implementations of Dijkstra's algorithm for finding shortest paths in graphs.

  This module provides two different approaches to solving the shortest path problem,
  each optimized for different use cases:

  ## Implementations

  ### 1. Tree-Based Implementation (`shortest_path_tree/2`, `shortest_path/3`)
  Classic Dijkstra's algorithm that builds a complete shortest path tree from source to all nodes.

  ### 2. Search-Based Implementation (`shortest_path_search/3`)
  Path-based approach with early termination, optimized for single source-destination queries.

  ## Algorithm Design Differences

  | Aspect             | `shortest_path_tree/2`                    | `shortest_path_search/3`            |
  |--------------------|-------------------------------------------|-------------------------------------|
  | **Algorithm Type** | Classic Dijkstra (tree-building)          | Modified Dijkstra (targeted search) |
  | **Scope**          | Source → **ALL nodes**                    | Source → **SPECIFIC destination**   |
  | **Termination**    | When all nodes processed                  | When **destination found**          |
  | **Data Structure** | Distance map + previous pointers          | Complete paths in priority queue    |
  | **Use Case**       | Multiple destination queries              | Single destination queries          |
  | **Memory Usage**   | O(V)                                      | O(V × P) where P = path length      |
  | **Performance**    | Always explores all reachable             | **Early termination** advantage     |
  | **Graph Format**   | `Graph` struct with adjacency list        | Map with `{cost, neighbor}` tuples  |
  | **Return Value**   | `{:ok, {distance, path}}` or distance map | `{total_cost, complete_path}`       |

  ## When to Use Which Implementation

  **Use `shortest_path_tree/2` when:**
  - You need distances to multiple destinations from the same source
  - You're working with the structured `Graph` format
  - You want the classic academic Dijkstra implementation
  - Memory efficiency is important (O(V) vs O(V×P))

  **Use `shortest_path_search/3` when:**
  - You need a path to a single specific destination
  - You want early termination for better performance
  - You're working with simple map-based graphs
  - You need the complete path immediately without reconstruction

  ## Recommendation Matrix

  | Use Case                        | Recommended Implementation | Reason                           |
  |---------------------------------|---------------------------|-----------------------------------|
  | Single path, sparse graph       | `shortest_path_search/3`  | Early termination advantage       |
  | Multiple paths, same source     | `shortest_path_tree/2`    | Amortized cost benefits           |
  | Memory-constrained environment  | `shortest_path_tree/2`    | O(V) vs O(V×P) memory             |
  | Dense graphs                    | `shortest_path_tree/2`    | Avoids path explosion             |
  | Production systems              | `shortest_path_tree/2`    | Standard, well-tested approach    |
  | Coding interviews               | `shortest_path_search/3`  | Easier to implement under pressure|
  | Educational purposes            | `shortest_path_tree/2`    | Matches academic literature       |
  | Quick prototyping               | `shortest_path_search/3`  | Faster to implement               |

  ## Classic Dijkstra Algorithm Overview

  The algorithm works by:
  1. Initialize distances to all nodes as infinity, except the source node (distance 0)
  2. Create a priority queue with all nodes, prioritized by distance
  3. While the queue is not empty:
     - Extract the node with minimum distance
     - For each neighbor of the current node:
       - Calculate the distance through the current node
       - If this distance is shorter than the known distance, update it

  Time Complexity: O((V + E) log V) where V is vertices and E is edges
  Space Complexity: O(V) for the distance map and priority queue
  """

  @doc """
  Builds a shortest path tree from source to all other nodes in the graph.

  Uses the classic Dijkstra's algorithm approach that computes shortest distances
  to all reachable nodes, creating a shortest path tree structure.

  Returns a map where keys are nodes and values are tuples of {distance, previous_node}.
  The previous_node can be used to reconstruct the actual path.

  ## Examples

      iex> graph = Algorithms.Dijkstra.Graph.new()
      ...> |> Algorithms.Dijkstra.Graph.add_edge("A", "B", 4)
      ...> |> Algorithms.Dijkstra.Graph.add_edge("A", "C", 2)
      ...> |> Algorithms.Dijkstra.Graph.add_edge("B", "C", 1)
      ...> |> Algorithms.Dijkstra.Graph.add_edge("B", "D", 5)
      ...> |> Algorithms.Dijkstra.Graph.add_edge("C", "D", 8)
      ...> |> Algorithms.Dijkstra.Graph.add_edge("C", "E", 10)
      ...> |> Algorithms.Dijkstra.Graph.add_edge("D", "E", 2)
      iex> Algorithms.Dijkstra.shortest_path_tree(graph, "A")
      %{
        "A" => {0, nil},
        "B" => {4, "A"},
        "C" => {2, "A"},
        "D" => {9, "B"},
        "E" => {11, "D"}
      }
  """
  def shortest_path_tree(graph = %Graph{}, source) do
    all_nodes = Graph.all_nodes(graph)

    # Initialize distances: source = 0, all others = infinity
    distances =
      all_nodes
      |> Enum.reduce(%{}, fn node, acc ->
        distance = if node == source, do: 0, else: :infinity
        Map.put(acc, node, {distance, nil})
      end)

    # Priority queue: list of {distance, node} tuples, sorted by distance
    queue = [{0, source}]
    visited = MapSet.new()

    dijkstra_loop(graph, queue, distances, visited)
  end

  @doc """
  Finds the shortest path between two specific nodes.

  Returns {:ok, {distance, path}} if a path exists, or {:error, :no_path} if no path exists.

  ## Examples

      iex> graph = Algorithms.Dijkstra.Graph.new()
      ...> |> Algorithms.Dijkstra.Graph.add_edge("A", "B", 4)
      ...> |> Algorithms.Dijkstra.Graph.add_edge("A", "C", 2)
      ...> |> Algorithms.Dijkstra.Graph.add_edge("C", "B", 1)
      iex> Algorithms.Dijkstra.shortest_path(graph, "A", "B")
      {:ok, {3, ["A", "C", "B"]}}
  """
  def shortest_path(graph = %Graph{}, source, destination) do
    distances = shortest_path_tree(graph, source)

    case Map.get(distances, destination) do
      {distance, _} when distance == :infinity ->
        {:error, :no_path}

      {distance, _} ->
        path = reconstruct_path(distances, source, destination)
        {:ok, {distance, path}}
    end
  end

  # Main Dijkstra's algorithm loop
  defp dijkstra_loop(_graph, [], distances, _visited), do: distances

  defp dijkstra_loop(graph, queue, distances, visited) do
    # Sort queue by distance and take the minimum
    [{current_distance, current_node} | rest_queue] = Enum.sort(queue)

    # Skip if already visited
    if MapSet.member?(visited, current_node) do
      dijkstra_loop(graph, rest_queue, distances, visited)
    else
      # Mark as visited
      new_visited = MapSet.put(visited, current_node)

      # Process neighbors
      neighbors = Graph.neighbors(graph, current_node)

      {new_queue, new_distances} =
        process_neighbors(
          neighbors,
          current_node,
          current_distance,
          rest_queue,
          distances,
          new_visited
        )

      dijkstra_loop(graph, new_queue, new_distances, new_visited)
    end
  end

  # Process all neighbors of the current node
  defp process_neighbors(neighbors, current_node, current_distance, queue, distances, visited) do
    Enum.reduce(neighbors, {queue, distances}, fn {neighbor, weight},
                                                  {acc_queue, acc_distances} ->
      process_single_neighbor(
        neighbor,
        weight,
        current_node,
        current_distance,
        acc_queue,
        acc_distances,
        visited
      )
    end)
  end

  # Process a single neighbor and update queue/distances if a shorter path is found
  defp process_single_neighbor(
         neighbor,
         weight,
         current_node,
         current_distance,
         acc_queue,
         acc_distances,
         visited
       ) do
    # Skip if already visited
    if MapSet.member?(visited, neighbor) do
      {acc_queue, acc_distances}
    else
      {current_neighbor_distance, _} = Map.get(acc_distances, neighbor, {:infinity, nil})
      new_distance = current_distance + weight

      # If we found a shorter path, update it
      if new_distance < current_neighbor_distance do
        updated_distances = Map.put(acc_distances, neighbor, {new_distance, current_node})
        updated_queue = [{new_distance, neighbor} | acc_queue]
        {updated_queue, updated_distances}
      else
        {acc_queue, acc_distances}
      end
    end
  end

  # Reconstruct the path from source to destination using the previous node information
  defp reconstruct_path(distances, source, destination) do
    build_path(distances, destination, [destination], source)
  end

  defp build_path(_distances, source, path, source), do: path

  defp build_path(distances, current, path, source) do
    {_, previous} = Map.get(distances, current)
    build_path(distances, previous, [previous | path], source)
  end

  @doc """
  Performs targeted shortest path search from source to specific destination.

  This implementation uses a path-based approach that maintains complete paths
  and costs in a priority queue, with early termination when the destination is found.
  More efficient for single source-destination queries compared to building full tree.

  Graph format: A map where each node maps to a list of {cost, neighbor} tuples.

  Returns: {total_cost, path_list} or {0, []} if no path exists.

  ## Examples

      iex> graph = %{
      ...>   :a => [{7, :b}, {9, :c}, {14, :f}],
      ...>   :b => [{7, :a}, {10, :c}, {15, :d}],
      ...>   :c => [{10, :b}, {9, :a}, {11, :d}, {2, :f}],
      ...>   :d => [{15, :b}, {6, :e}, {11, :c}],
      ...>   :e => [{9, :f}, {6, :d}],
      ...>   :f => [{14, :a}, {2, :c}, {9, :e}]
      ...> }
      iex> Algorithms.Dijkstra.shortest_path_search(graph, :a, :e)
      {20, [:a, :c, :f, :e]}
  """
  def shortest_path_search(graph, start, destination) when is_map(graph) do
    shortest_path_search_impl(graph, [{0, [start]}], destination, %{})
  end

  # Base case: empty routes, no path found
  defp shortest_path_search_impl(_graph, [], _destination, _visited) do
    {0, []}
  end

  # Base case: reached destination
  defp shortest_path_search_impl(
         _graph,
         [{cost, [destination | _] = path} | _],
         destination,
         _visited
       ) do
    {cost, Enum.reverse(path)}
  end

  # Recursive case: explore neighbors
  defp shortest_path_search_impl(
         graph,
         [{cost, [node | _] = path} | routes],
         destination,
         visited
       ) do
    # Get neighbors of current node, defaulting to empty list if node not in graph
    neighbors = Map.get(graph, node, [])

    # Build new routes for unvisited neighbors
    new_routes =
      for {new_cost, new_node} <- neighbors,
          not Map.get(visited, new_node, false),
          do: {cost + new_cost, [new_node | path]}

    # Continue with sorted routes (shortest cost first) and mark current node as visited
    shortest_path_search_impl(
      graph,
      Enum.sort(new_routes ++ routes),
      destination,
      Map.put(visited, node, true)
    )
  end
end
