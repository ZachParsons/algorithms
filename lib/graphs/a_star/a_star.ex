defmodule Algorithms.Graphs.AStar do
  @moduledoc """
  A* search algorithm implementation for finding the lowest cost path between two nodes.

  The A* algorithm is an extension of Dijkstra's algorithm that uses a heuristic function
  to guide the search towards the goal, making it more efficient for pathfinding.
  """
  alias Algorithms.PriorityQueue

  defmodule Graph do
    @moduledoc """
    Graph representation with support for grid generation and barriers.
    """

    defstruct links: %{}

    @type position :: {integer(), integer()}
    @type t :: %__MODULE__{links: %{position() => %{position() => integer()}}}

    def new, do: %__MODULE__{}

    def grid(width, height) do
      links =
        for x <- 0..width, y <- 0..height, into: %{} do
          neighbors =
            for dx <- -1..1,
                dy <- -1..1,
                dx != 0 or dy != 0,
                nx = x + dx,
                ny = y + dy,
                nx >= 0 and nx <= width and ny >= 0 and ny <= height,
                into: %{} do
              # Cost calculation: diagonal moves cost more than orthogonal
              # All moves cost 1 as per problem
              cost = if abs(dx) + abs(dy) == 2, do: 1, else: 1
              {{nx, ny}, cost}
            end

          {{x, y}, neighbors}
        end

      %__MODULE__{links: links}
    end

    def with_barriers(%__MODULE__{links: links}, barriers, barrier_cost \\ 100) do
      updated_links =
        for {pos, neighbors} <- links, into: %{} do
          if pos in barriers do
            # Barrier positions can still be traversed but with high cost
            updated_neighbors =
              for {neighbor_pos, _cost} <- neighbors, into: %{} do
                {neighbor_pos, barrier_cost}
              end

            {pos, updated_neighbors}
          else
            # Update costs to barrier neighbors
            updated_neighbors =
              for {neighbor_pos, cost} <- neighbors, into: %{} do
                if neighbor_pos in barriers do
                  {neighbor_pos, barrier_cost}
                else
                  {neighbor_pos, cost}
                end
              end

            {pos, updated_neighbors}
          end
        end

      %__MODULE__{links: updated_links}
    end

    def neighbors(%__MODULE__{links: links}, position) do
      Map.get(links, position, %{})
    end
  end

  @doc """
  Find the shortest path using A* algorithm.

  ## Parameters
  - graph: The graph to search
  - heuristic_fn: Function that estimates cost from current position to goal
  - start: Starting position
  - goal: Goal position

  ## Returns
  - List of positions representing the optimal path, or empty list if no path found
  """
  def find_path(graph, heuristic_fn, start, goal) do
    initial_state = %{
      came_from: %{},
      g_score: %{start => 0},
      open_set: PriorityQueue.enqueue(PriorityQueue.new(), start, heuristic_fn.(start))
    }

    search_loop(graph, heuristic_fn, goal, initial_state)
  end

  defp search_loop(graph, heuristic_fn, goal, state) do
    case PriorityQueue.dequeue(state.open_set) do
      {nil, _} ->
        # No path found
        []

      {current, new_open_set} ->
        if current == goal do
          reconstruct_path(state.came_from, goal)
        else
          new_state = %{state | open_set: new_open_set}
          updated_state = process_neighbors(graph, heuristic_fn, goal, current, new_state)
          search_loop(graph, heuristic_fn, goal, updated_state)
        end
    end
  end

  defp process_neighbors(graph, heuristic_fn, _goal, current, state) do
    neighbors = Graph.neighbors(graph, current)
    current_g_score = Map.get(state.g_score, current, :infinity)

    Enum.reduce(neighbors, state, fn {neighbor, edge_cost}, acc_state ->
      tentative_g_score = current_g_score + edge_cost
      neighbor_g_score = Map.get(acc_state.g_score, neighbor, :infinity)

      if tentative_g_score < neighbor_g_score do
        f_score = tentative_g_score + heuristic_fn.(neighbor)

        %{
          came_from: Map.put(acc_state.came_from, neighbor, current),
          g_score: Map.put(acc_state.g_score, neighbor, tentative_g_score),
          open_set: PriorityQueue.enqueue(acc_state.open_set, neighbor, f_score)
        }
      else
        acc_state
      end
    end)
  end

  defp reconstruct_path(came_from, goal) do
    build_path(came_from, goal, [goal])
  end

  defp build_path(came_from, current, path) do
    case Map.get(came_from, current) do
      nil -> path
      parent -> build_path(came_from, parent, [parent | path])
    end
  end

  @doc """
  Chebyshev distance heuristic (maximum of horizontal and vertical distance).
  This is admissible for 8-directional movement where diagonal moves have the same cost.
  """
  def chebyshev_distance({x1, y1}, {x2, y2}) do
    max(abs(x1 - x2), abs(y1 - y2))
  end

  @doc """
  Manhattan distance heuristic (sum of horizontal and vertical distance).
  """
  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  @doc """
  Solve the chess board problem as specified in the task.
  """
  def solve_chess_board_problem do
    # Create 8x8 grid (0-7 in each dimension)
    graph = Graph.grid(7, 7)

    # Define barriers as specified in the problem
    barriers = [
      {2, 4},
      {2, 5},
      {2, 6},
      {3, 6},
      {4, 6},
      {5, 6},
      {5, 5},
      {5, 4},
      {5, 3},
      {5, 2},
      {4, 2},
      {3, 2}
    ]

    # Add barriers with cost 100
    graph_with_barriers = Graph.with_barriers(graph, barriers, 100)

    start = {0, 0}
    goal = {7, 7}

    # Use Chebyshev distance as heuristic (appropriate for 8-directional movement)
    heuristic_fn = fn pos -> chebyshev_distance(pos, goal) end

    path = find_path(graph_with_barriers, heuristic_fn, start, goal)

    if path != [] do
      cost = calculate_path_cost(graph_with_barriers, path)
      {path, cost}
    else
      {[], :infinity}
    end
  end

  def calculate_path_cost(_graph, [_single_node]), do: 0

  def calculate_path_cost(graph, [current | [next | _] = rest]) do
    neighbors = Graph.neighbors(graph, current)
    edge_cost = Map.get(neighbors, next, 0)
    edge_cost + calculate_path_cost(graph, rest)
  end

  @doc """
  Example usage and testing function.
  """
  def example do
    solve_chess_board_problem()
  end
end
