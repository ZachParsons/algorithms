defmodule Algorithms.Graphs.TSP.BB do
  @moduledoc """
  Traveling Salesman Problem using Branch and Bound Algorithm

  This implementation solves the TSP using the branch and bound technique,
  which prunes the search space by computing lower bounds and eliminating
  paths that cannot lead to optimal solutions.

  Functional programming approach emphasizing immutability, function composition,
  and declarative style.

  ## Mnemonic
  Build: Initial bound from sum of each vertex's two minimum edges ÷ 2
  Branch: Generate all unvisited cities as next states with updated costs/bounds
  Bound: Filter states where (current_cost + lower_bound) < best_known_solution
  Recurse: Explore promising states depth-first, updating best solution found
  Complete: Add return-to-start cost when all cities visited
  Choose: Keep solution with minimum total tour cost

  Time Complexity: O(n!) in worst case, but typically much better due to pruning
  Space Complexity: O(n) for the recursion stack and visited set
  """

  # State structure for TSP search
  defstruct [:matrix, :n, :visited, :path, :cost, :bound, :level]

  @type tsp_state :: %__MODULE__{
          matrix: [[non_neg_integer()]],
          n: non_neg_integer(),
          visited: MapSet.t(non_neg_integer()),
          path: [non_neg_integer()],
          cost: non_neg_integer(),
          bound: non_neg_integer(),
          level: non_neg_integer()
        }

  @type solution :: {non_neg_integer() | :infinity, [non_neg_integer()]}

  @doc """
  Solves the TSP using Branch and Bound algorithm.

  ## Parameters
  - `adj_matrix`: A 2D list representing the adjacency matrix where adj_matrix[i][j]
    is the cost of traveling from city i to city j. Use 0 for no direct path.

  ## Returns
  - `{min_cost, path}`: A tuple containing the minimum cost and the optimal path

  ## Example
      iex> adj_matrix = [
      ...>   [0, 10, 15, 20],
      ...>   [10, 0, 35, 25],
      ...>   [15, 35, 0, 30],
      ...>   [20, 25, 30, 0]
      ...> ]
      iex> Algorithms.Graphs.TSP.BB.run(adj_matrix)
      {80, [0, 1, 3, 2, 0]}
  """
  @spec run([[non_neg_integer()]]) :: solution()
  def run(adj_matrix) when is_list(adj_matrix) do
    adj_matrix
    |> create_initial_state()
    |> solve()
    |> complete_tour()
  end

  # Create initial state for the TSP search
  @spec create_initial_state([[non_neg_integer()]]) :: tsp_state() | solution()
  defp create_initial_state([]), do: {0, []}
  defp create_initial_state([_]), do: {0, [0]}

  defp create_initial_state(matrix) do
    n = length(matrix)
    initial_bound = calculate_lower_bound(matrix)

    %__MODULE__{
      matrix: matrix,
      n: n,
      visited: MapSet.new([0]),
      path: [0],
      cost: 0,
      bound: initial_bound,
      level: 1
    }
  end

  # Main solver function using functional approach
  @spec solve(tsp_state() | solution()) :: solution()
  # Base case for trivial solutions
  defp solve({cost, path}), do: {cost, path}

  defp solve(state) do
    state
    |> branch_and_bound({:infinity, []})
  end

  # Complete the tour by adding return to start city
  @spec complete_tour(solution()) :: solution()
  defp complete_tour({cost, path}) when length(path) <= 1, do: {cost, path}
  defp complete_tour({cost, path}), do: {cost, path ++ [0]}

  # Branch and bound recursive search
  @spec branch_and_bound(tsp_state(), solution()) :: solution()
  defp branch_and_bound(%{level: level, n: n} = state, best_solution) when level == n do
    state
    |> try_complete_tour()
    |> choose_better_solution(best_solution)
  end

  defp branch_and_bound(state, best_solution) do
    state
    |> generate_next_states()
    |> filter_promising_states(best_solution)
    |> explore_states(best_solution)
  end

  # Try to complete the tour from current state
  @spec try_complete_tour(tsp_state()) :: solution()
  defp try_complete_tour(%{matrix: matrix, path: path, cost: cost}) do
    last_city = List.last(path)
    return_cost = get_edge_cost(matrix, last_city, 0)

    if return_cost > 0 do
      {cost + return_cost, path}
    else
      {:infinity, []}
    end
  end

  # Generate all possible next states from current state
  @spec generate_next_states(tsp_state()) :: [tsp_state()]
  defp generate_next_states(state = %{n: n}) do
    0..(n - 1)
    |> Enum.reject(&MapSet.member?(state.visited, &1))
    |> Enum.map(&create_next_state(state, &1))
    |> Enum.reject(&is_nil/1)
  end

  # Create next state by visiting a specific city
  @spec create_next_state(tsp_state(), non_neg_integer()) :: tsp_state() | nil
  defp create_next_state(state, next_city) do
    current_city = List.last(state.path)
    edge_cost = get_edge_cost(state.matrix, current_city, next_city)

    if edge_cost > 0 do
      new_cost = state.cost + edge_cost
      new_bound = calculate_new_bound(state, current_city, next_city)

      %{
        state
        | visited: MapSet.put(state.visited, next_city),
          path: state.path ++ [next_city],
          cost: new_cost,
          bound: new_bound,
          level: state.level + 1
      }
    else
      nil
    end
  end

  # Filter states that are promising (bound + cost < best known solution)
  @spec filter_promising_states([tsp_state()], solution()) :: [tsp_state()]
  defp filter_promising_states(states, {:infinity, _}), do: states

  defp filter_promising_states(states, {best_cost, _}) do
    states
    |> Enum.filter(fn %{bound: bound, cost: cost} ->
      bound + cost < best_cost
    end)
  end

  # Explore all promising states and find the best solution
  @spec explore_states([tsp_state()], solution()) :: solution()
  defp explore_states([], best_solution), do: best_solution

  defp explore_states([state | rest], best_solution) do
    new_solution = branch_and_bound(state, best_solution)
    better_solution = choose_better_solution(new_solution, best_solution)
    explore_states(rest, better_solution)
  end

  # Choose the better of two solutions
  @spec choose_better_solution(solution(), solution()) :: solution()
  defp choose_better_solution({:infinity, _}, solution2), do: solution2
  defp choose_better_solution(solution1, {:infinity, _}), do: solution1
  defp choose_better_solution({cost1, path1}, {cost2, _}) when cost1 < cost2, do: {cost1, path1}
  defp choose_better_solution(_, solution2), do: solution2

  # Calculate lower bound for the entire matrix
  @spec calculate_lower_bound([[non_neg_integer()]]) :: non_neg_integer()
  defp calculate_lower_bound(matrix) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, vertex} ->
      {first_min, second_min} = find_two_minimums(row, vertex)
      first_min + second_min
    end)
    |> Enum.sum()
    |> then(&div(&1 + 1, 2))
  end

  # Calculate new bound when transitioning to next city
  @spec calculate_new_bound(tsp_state(), non_neg_integer(), non_neg_integer()) ::
          non_neg_integer()
  defp calculate_new_bound(%{matrix: matrix, bound: curr_bound, level: level}, from_city, to_city) do
    reduction =
      case level do
        1 -> div(first_min(matrix, from_city) + first_min(matrix, to_city), 2)
        _ -> div(second_min(matrix, from_city) + first_min(matrix, to_city), 2)
      end

    curr_bound - reduction
  end

  # Find the two minimum edge costs for a given vertex
  @spec find_two_minimums([non_neg_integer()], non_neg_integer()) ::
          {non_neg_integer(), non_neg_integer()}
  defp find_two_minimums(row, vertex_index) do
    row
    |> Enum.with_index()
    |> Enum.reject(fn {cost, idx} -> idx == vertex_index or cost == 0 end)
    |> Enum.map(fn {cost, _idx} -> cost end)
    |> Enum.sort()
    |> case do
      [] -> {0, 0}
      [min] -> {min, 0}
      [first, second | _] -> {first, second}
    end
  end

  # Get edge cost between two cities
  @spec get_edge_cost([[non_neg_integer()]], non_neg_integer(), non_neg_integer()) ::
          non_neg_integer()
  defp get_edge_cost(matrix, from, to) do
    matrix |> Enum.at(from) |> Enum.at(to)
  end

  # Find minimum edge cost from a vertex
  @spec first_min([[non_neg_integer()]], non_neg_integer()) :: non_neg_integer()
  defp first_min(matrix, vertex) do
    matrix
    |> Enum.at(vertex)
    |> extract_valid_costs(vertex)
    |> case do
      [] -> 0
      costs -> Enum.min(costs)
    end
  end

  # Find second minimum edge cost from a vertex
  @spec second_min([[non_neg_integer()]], non_neg_integer()) :: non_neg_integer()
  defp second_min(matrix, vertex) do
    matrix
    |> Enum.at(vertex)
    |> extract_valid_costs(vertex)
    |> Enum.sort()
    |> case do
      [] -> 0
      [_] -> 0
      [_, second | _] -> second
    end
  end

  # Extract valid costs (non-zero, not self-loop)
  @spec extract_valid_costs([non_neg_integer()], non_neg_integer()) :: [non_neg_integer()]
  defp extract_valid_costs(row, vertex_index) do
    row
    |> Enum.with_index()
    |> Enum.reject(fn {cost, idx} -> idx == vertex_index or cost == 0 end)
    |> Enum.map(fn {cost, _idx} -> cost end)
  end
end
