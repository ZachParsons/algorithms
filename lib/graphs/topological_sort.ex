defmodule Algorithms.Graphs.TopologicalSort do
  @moduledoc """
  Implementation of topological sort to determine if all courses can be finished
  given their prerequisites. Returns true if possible, false if there's a cycle.

  Uses Kahn's algorithm with in-degree counting.

  ## Mnemonic

  Build: prereq_list → {adjacency_map, in_degree_counts}
  Queue: courses with zero dependencies (in_degree = 0)
  Process: pop course → decrement neighbors' in_degrees → queue newly freed courses
  Validate: processed_count = total_courses (no cycle detected)
  """

  def run(course_count, prereqs) do
    # Build adjacency list and in-degree count
    {adj_list, in_degree} = build_graph(course_count, prereqs)

    # Find all nodes with in-degree 0
    queue =
      0..(course_count - 1)
      |> Enum.filter(fn course -> Map.get(in_degree, course, 0) == 0 end)

    # Process nodes with BFS
    process_queue(queue, adj_list, in_degree, 0, course_count)
  end

  defp build_graph(course_count, prereqs) do
    # Initialize adjacency list and in-degree map
    adj_list =
      0..(course_count - 1)
      |> Enum.into(%{}, fn course -> {course, []} end)

    in_degree = %{}

    # Build the graph from prerequisites
    Enum.reduce(prereqs, {adj_list, in_degree}, fn [course, prereq], {adj, in_deg} ->
      # prereq -> course (prereq must be taken before course)
      new_adj = Map.update!(adj, prereq, fn neighbors -> [course | neighbors] end)
      new_in_deg = Map.update(in_deg, course, 1, fn count -> count + 1 end)
      {new_adj, new_in_deg}
    end)
  end

  defp process_queue([], _adj_list, _in_degree, processed_count, course_count) do
    # If we processed all courses, no cycle exists
    processed_count == course_count
  end

  defp process_queue([current | rest], adj_list, in_degree, processed_count, course_count) do
    # Get neighbors of current course
    neighbors = Map.get(adj_list, current, [])

    # Reduce in-degree of all neighbors
    {new_queue, new_in_degree} =
      Enum.reduce(neighbors, {rest, in_degree}, fn neighbor, {queue_acc, in_deg_acc} ->
        new_count = Map.get(in_deg_acc, neighbor, 0) - 1
        new_in_deg = Map.put(in_deg_acc, neighbor, new_count)

        # If in-degree becomes 0, add to queue
        if new_count == 0 do
          {[neighbor | queue_acc], new_in_deg}
        else
          {queue_acc, new_in_deg}
        end
      end)

    # Continue processing with updated queue
    process_queue(new_queue, adj_list, new_in_degree, processed_count + 1, course_count)
  end
end
