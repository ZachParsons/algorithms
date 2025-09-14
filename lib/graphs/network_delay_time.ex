defmodule Algorithms.Graphs.NDT do
  # Network Delay Time problem solver
  # Returns the minimum time for all n nodes to receive the signal from source node k
  # Returns -1 if it's impossible for all nodes to receive the signal

  def network_delay_time(times, n, k) do
    # Build weighted adjacency list from times
    graph =
      Enum.reduce(times, %{}, fn %{source: from, target: to, weight: time}, acc ->
        neighbors = Map.get(acc, from, [])
        Map.put(acc, from, [{to, time} | neighbors])
      end)

    # Run Dijkstra's algorithm from source node k
    distances = dijkstra_shortest_paths(graph, k)

    # Check if all nodes (1 to n) are reachable
    all_nodes = 1..n |> Enum.to_list()

    reachable_distances =
      Enum.map(all_nodes, fn node ->
        Map.get(distances, node, :infinity)
      end)

    # If any node is unreachable, return -1
    if Enum.any?(reachable_distances, &(&1 == :infinity)) do
      -1
    else
      # Return the maximum time (when the last node receives the signal)
      Enum.max(reachable_distances)
    end
  end

  # Dijkstra's algorithm implementation for network delay time problem
  defp dijkstra_shortest_paths(graph, source) do
    # Initialize distances: source = 0, all others = infinity
    distances = %{source => 0}

    # Priority queue: list of {distance, node} tuples
    queue = [{0, source}]
    visited = MapSet.new()

    dijkstra_loop_network(graph, queue, distances, visited)
  end

  defp dijkstra_loop_network(_graph, [], distances, _visited), do: distances

  defp dijkstra_loop_network(graph, queue, distances, visited) do
    # Sort queue by distance and take the minimum
    [{current_distance, current_node} | rest_queue] = Enum.sort(queue)

    # Skip if already visited
    if MapSet.member?(visited, current_node) do
      dijkstra_loop_network(graph, rest_queue, distances, visited)
    else
      # Mark as visited
      new_visited = MapSet.put(visited, current_node)

      # Process neighbors
      neighbors = Map.get(graph, current_node, [])

      {new_queue, new_distances} =
        Enum.reduce(neighbors, {rest_queue, distances}, fn {neighbor, weight},
                                                           {acc_queue, acc_distances} ->
          new_distance = current_distance + weight
          current_neighbor_distance = Map.get(acc_distances, neighbor, :infinity)

          # If we found a shorter path, update it
          if new_distance < current_neighbor_distance do
            updated_distances = Map.put(acc_distances, neighbor, new_distance)
            updated_queue = [{new_distance, neighbor} | acc_queue]
            {updated_queue, updated_distances}
          else
            {acc_queue, acc_distances}
          end
        end)

      dijkstra_loop_network(graph, new_queue, new_distances, new_visited)
    end
  end
end
