defmodule Algorithms.Graphs.Graph do
  @moduledoc """
  A unified weighted graph implementation supporting both general graphs and spatial grids.

  This module combines the functionality of general weighted graphs with optimized
  2D grid operations, making it suitable for both abstract graph algorithms and
  spatial pathfinding problems.
  """

  alias Algorithms.PriorityQueue

  # General graph structure using adjacency lists
  defstruct nodes: %{}, links: %{}

  # A* specific graph structure for grid-based pathfinding
  defmodule Grid do
    @moduledoc """
    Graph representation with support for grid generation and barriers.
    This is the original Graph module from AStar, moved here for consolidation.
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

  @type graph_node :: any()
  @type position :: {integer(), integer()}
  @type weight :: number()
  @type t :: %__MODULE__{nodes: %{graph_node() => [{graph_node(), weight()}]}}

  @spec new() :: Algorithms.Graphs.Graph.t()
  @doc """
  Creates a new empty graph.
  """
  def new, do: %__MODULE__{}

  ## ====================================================================
  ## General Graph Operations (from WeightedGraph)
  ## ====================================================================

  @doc """
  Adds an edge from source to target with the given weight.
  For undirected graphs, you need to add edges in both directions.
  """
  def add_edge(%__MODULE__{nodes: nodes} = graph, from, to, weight) when weight >= 0 do
    neighbors = Map.get(nodes, from, [])
    updated_neighbors = [{to, weight} | neighbors]
    %{graph | nodes: Map.put(nodes, from, updated_neighbors)}
  end

  @doc """
  Adds a bidirectional edge (for undirected graphs).
  """
  def add_undirected_edge(graph, from, to, weight) do
    graph
    |> add_edge(from, to, weight)
    |> add_edge(to, from, weight)
  end

  @doc """
  Adds multiple directed edges in one call.

  ## Examples

      iex> graph = Algorithms.Graphs.Graph.new()
      ...> |> Algorithms.Graphs.Graph.add_edges([
      ...>   {"A", "B", 4},
      ...>   {"A", "C", 2},
      ...>   {"B", "D", 5}
      ...> ])
      iex> Algorithms.Graphs.Graph.neighbors(graph, "A")
      [{"C", 2}, {"B", 4}]
  """
  def add_edges(graph, edges) when is_list(edges) do
    Enum.reduce(edges, graph, fn {from, to, weight}, acc ->
      add_edge(acc, from, to, weight)
    end)
  end

  @doc """
  Adds multiple undirected edges in one call.
  """
  def add_undirected_edges(graph, edges) when is_list(edges) do
    Enum.reduce(edges, graph, fn {from, to, weight}, acc ->
      add_undirected_edge(acc, from, to, weight)
    end)
  end

  ## ====================================================================
  ## Grid Operations (from AStar.Graph)
  ## ====================================================================

  @doc """
  Creates a 2D grid graph with 8-directional movement (like a chess king).

  ## Parameters
  - width: Maximum x coordinate (0 to width inclusive)
  - height: Maximum y coordinate (0 to height inclusive)

  ## Returns
  A graph where each position {x, y} connects to up to 8 neighbors with cost 1.
  """
  def grid(width, height) do
    edges =
      for x <- 0..width,
          y <- 0..height,
          dx <- -1..1,
          dy <- -1..1,
          dx != 0 or dy != 0,
          nx = x + dx,
          ny = y + dy,
          nx >= 0 and nx <= width and ny >= 0 and ny <= height do
        {{x, y}, {nx, ny}, 1}
      end

    new() |> add_edges(edges)
  end

  @doc """
  Adds barriers to a grid graph by increasing the cost of moving to/from barrier positions.

  ## Parameters
  - graph: The graph to modify
  - barriers: List of positions that act as barriers
  - barrier_cost: Cost of moving to/from barrier positions (default: 100)
  """
  def with_barriers(graph, barriers, barrier_cost \\ 100) do
    # Convert current edges to list format and update barrier costs
    all_edges =
      for {from, neighbors} <- graph.nodes,
          {to, current_cost} <- neighbors do
        new_cost =
          cond do
            from in barriers or to in barriers -> barrier_cost
            true -> current_cost
          end

        {from, to, new_cost}
      end

    # Rebuild graph with updated costs
    new() |> add_edges(all_edges)
  end

  ## ====================================================================
  ## Common Operations
  ## ====================================================================

  @doc """
  Gets all neighbors of a node.
  Returns a list of {neighbor, weight} tuples.
  """
  def neighbors(%__MODULE__{nodes: nodes}, node) do
    Map.get(nodes, node, [])
  end

  @doc """
  Gets neighbors as a map (for compatibility with AStar algorithm).
  Returns a map of %{neighbor => weight}.
  """
  def neighbors_map(graph, node) do
    neighbors(graph, node)
    |> Enum.into(%{})
  end

  @doc """
  Gets all nodes in the graph.
  """
  def all_nodes(%__MODULE__{nodes: nodes}) do
    # Get all nodes that appear as keys or in neighbor lists
    keys = Map.keys(nodes)
    neighbor_nodes = nodes |> Map.values() |> List.flatten() |> Enum.map(&elem(&1, 0))
    (keys ++ neighbor_nodes) |> Enum.uniq()
  end

  ## ====================================================================
  ## A* Algorithm Implementation
  ## ====================================================================

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
          updated_state = process_neighbors(graph, heuristic_fn, current, new_state)
          search_loop(graph, heuristic_fn, goal, updated_state)
        end
    end
  end

  defp process_neighbors(graph, heuristic_fn, current, state) do
    neighbors = neighbors(graph, current)
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

  ## ====================================================================
  ## Heuristic Functions
  ## ====================================================================

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
  Euclidean distance heuristic.
  """
  def euclidean_distance({x1, y1}, {x2, y2}) do
    :math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
  end

  ## ====================================================================
  ## Utility Functions
  ## ====================================================================

  @doc """
  Calculate the total cost of a path.
  """
  def calculate_path_cost(_graph, [_single_node]), do: 0

  def calculate_path_cost(graph, [current | [next | _] = rest]) do
    neighbors = neighbors(graph, current)

    edge_cost =
      Enum.find_value(neighbors, 0, fn {node, cost} ->
        if node == next, do: cost
      end)

    edge_cost + calculate_path_cost(graph, rest)
  end

  ## ====================================================================
  ## Example Problems
  ## ====================================================================

  @doc """
  Solve the chess board problem as specified in the A* task.
  """
  def solve_chess_board_problem do
    # Create 8x8 grid (0-7 in each dimension)
    graph = grid(7, 7)

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
    graph_with_barriers = with_barriers(graph, barriers, 100)

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

  @doc """
  Example usage and testing function.
  """
  def example do
    solve_chess_board_problem()
  end
end
