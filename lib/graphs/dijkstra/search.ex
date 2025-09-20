defmodule Algorithms.Graphs.Dijkstra.Search do
  @moduledoc """
  Search-Based Dijkstra's Algorithm Implementation

  Path-based approach with early termination, optimized for single source-target queries.
  This implementation uses a path-based approach that maintains complete paths and costs
  in a priority queue, with early termination when the target is found.

  ## Characteristics
  - **Algorithm Type**: Modified Dijkstra (targeted search)
  - **Scope**: Source → **SPECIFIC target**
  - **Termination**: When **target found**
  - **Data Structure**: Complete paths in priority queue
  - **Use Case**: Single target queries
  - **Memory Usage**: O(V × P) where P = path length
  - **Performance**: **Early termination** advantage
  - **Graph Format**: Map with `{cost, neighbor}` tuples
  - **Return Value**: `{total_cost, complete_path}`

  ## When to Use
  - You need a path to a single specific target
  - You want early termination for better performance
  - You're working with simple map-based graphs
  - You need the complete path immediately without reconstruction
  - Coding interviews (easier to implement under pressure)
  - Quick prototyping (faster to implement)
  - Single path, sparse graph scenarios

  ## Algorithm Overview
  This implementation maintains complete paths in the priority queue and terminates
  as soon as the target is reached, making it more efficient for single-target queries
  compared to building a full shortest path tree.

  Time Complexity: O((V + E) log V) in worst case, but often better due to early termination
  Space Complexity: O(V × P) where P is the average path length
  """

  @doc """
  Performs targeted shortest path search from source to specific target.

  This implementation uses a path-based approach that maintains complete paths
  and costs in a priority queue, with early termination when the target is found.
  More efficient for single source-target queries compared to building full tree.

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
      iex> Algorithms.Graphs.Dijkstra.Search.shortest_path_search(graph, :a, :e)
      {20, [:a, :c, :f, :e]}
  """
  def shortest_path_search(graph, start, target) when is_map(graph) do
    do_shortest_path_search(graph, [{0, [start]}], target, %{})
  end

  # Base case: empty routes, no path found
  defp do_shortest_path_search(_graph, [], _target, _visited) do
    {0, []}
  end

  # Base case: reached target
  defp do_shortest_path_search(
         _graph,
         [{cost, [target | _] = path} | _],
         target,
         _visited
       ) do
    {cost, Enum.reverse(path)}
  end

  # Recursive case: explore neighbors
  defp do_shortest_path_search(
         graph,
         [{cost, [node | _] = path} | routes],
         target,
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
    do_shortest_path_search(
      graph,
      Enum.sort(new_routes ++ routes),
      target,
      Map.put(visited, node, true)
    )
  end
end
