defmodule Algorithms.Graphs.Dijkstra.Tree do
  alias Algorithms.WeightedGraph

  @moduledoc """
  Tree-Based Dijkstra's Algorithm Implementation

  Classic Dijkstra's algorithm that builds a complete shortest path tree from source to all nodes.
  This implementation computes shortest distances to all reachable nodes, creating a shortest
  path tree structure.

  ## Characteristics
  - **Algorithm Type**: Classic Dijkstra (tree-building)
  - **Scope**: Source → **ALL nodes**
  - **Termination**: When all nodes processed
  - **Data Structure**: Distance map + previous pointers
  - **Use Case**: Multiple target queries
  - **Memory Usage**: O(V)
  - **Performance**: Always explores all reachable nodes
  - **Graph Format**: `WeightedGraph` struct with adjacency list
  - **Return Value**: `{:ok, {distance, path}}` or distance map

  ## When to Use
  - You need distances to multiple targets from the same source
  - You're working with the structured `WeightedGraph` format
  - You want the classic academic Dijkstra implementation
  - Memory efficiency is important (O(V) vs O(V×P))
  - Production systems (standard, well-tested approach)
  - Educational purposes (matches academic literature)

  ## Algorithm Overview
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

      iex> graph = Algorithms.WeightedGraph.new()
      ...> |> Algorithms.WeightedGraph.add_edge("A", "B", 4)
      ...> |> Algorithms.WeightedGraph.add_edge("A", "C", 2)
      ...> |> Algorithms.WeightedGraph.add_edge("B", "C", 1)
      ...> |> Algorithms.WeightedGraph.add_edge("B", "D", 5)
      ...> |> Algorithms.WeightedGraph.add_edge("C", "D", 8)
      ...> |> Algorithms.WeightedGraph.add_edge("C", "E", 10)
      ...> |> Algorithms.WeightedGraph.add_edge("D", "E", 2)
      iex> Algorithms.Graphs.Dijkstra.Tree.shortest_path_tree(graph, "A")
      %{
        "A" => {0, nil},
        "B" => {4, "A"},
        "C" => {2, "A"},
        "D" => {9, "B"},
        "E" => {11, "D"}
      }

  Triadic Pseudocode Protocol:
    ALGO Dijkstra(graph, start)
    ├── DATA: IN: graph, start → OUT: distances[]
    │   ├── PQ: min-heap (dist, node)
    │   ├── dist[]: ∞ except dist[start]=0
    │   └── prev[]: path reconstruction
    ├── ENUMERATE: WHILE PQ not empty
    │   └── u ← POP min-dist node
    └── CONDITIONAL:
        └── FOR neighbor v of u:
            ├── IF dist[v] > dist[u] + weight(u,v):
            │   ├── dist[v] ← dist[u] + weight(u,v)
            │   ├── prev[v] ← u
            │   └── PUSH (dist[v], v) to PQ

  Mnemonic:

  Base: graph → distance map {node: {dist, prev}} + priority queue
  Initialize: source distance=0, all others=infinity + visited set
  Main loop: while queue not empty
    Pop: minimum distance node from sorted queue
    If: already visited → skip to next
    Else: mark visited + process neighbors
      For: each unvisited neighbor
        If: new path shorter → update distance + add to queue
  Backtrack: follow previous pointers to reconstruct paths
  Output: complete distance map to all reachable nodes
  """
  def shortest_path_tree(graph = %WeightedGraph{}, source) do
    all_nodes = WeightedGraph.all_nodes(graph)

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

      iex> graph = Algorithms.WeightedGraph.new()
      ...> |> Algorithms.WeightedGraph.add_edge("A", "B", 4)
      ...> |> Algorithms.WeightedGraph.add_edge("A", "C", 2)
      ...> |> Algorithms.WeightedGraph.add_edge("C", "B", 1)
      iex> Algorithms.Graphs.Dijkstra.Tree.shortest_path(graph, "A", "B")
      {:ok, {3, ["A", "C", "B"]}}
  """
  def shortest_path(graph = %WeightedGraph{}, source, target) do
    distances = shortest_path_tree(graph, source)

    case Map.get(distances, target) do
      {distance, _} when distance == :infinity ->
        {:error, :no_path}

      {distance, _} ->
        path = reconstruct_path(distances, source, target)
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
      neighbors = WeightedGraph.neighbors(graph, current_node)

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

  # Reconstruct the path from source to target using the previous node information
  defp reconstruct_path(distances, source, target) do
    build_path(distances, target, [target], source)
  end

  defp build_path(_distances, source, path, source), do: path

  defp build_path(distances, current, path, source) do
    {_, previous} = Map.get(distances, current)
    build_path(distances, previous, [previous | path], source)
  end
end
