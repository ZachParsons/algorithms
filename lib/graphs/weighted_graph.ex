defmodule Algorithms.WeightedGraph do
  @moduledoc """
  Represents a weighted graph as an adjacency list.
  Each node maps to a list of {neighbor, weight} tuples.
  """
  defstruct nodes: %{}

  @type t :: %__MODULE__{nodes: %{any() => [{any(), number()}]}}

  @doc """
  Creates a new empty graph.
  """
  def new, do: %__MODULE__{}

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

  Accepts a list of {from, to, weight} tuples and adds each edge to the graph.

  ## Examples

      iex> graph = Algorithms.WeightedGraph.new()
      ...> |> Algorithms.WeightedGraph.add_edges([
      ...>   {"A", "B", 4},
      ...>   {"A", "C", 2},
      ...>   {"B", "D", 5}
      ...> ])
      iex> Algorithms.WeightedGraph.neighbors(graph, "A")
      [{"C", 2}, {"B", 4}]
  """
  def add_edges(graph, edges) when is_list(edges) do
    Enum.reduce(edges, graph, fn {from, to, weight}, acc ->
      add_edge(acc, from, to, weight)
    end)
  end

  @doc """
  Adds multiple undirected edges in one call.

  Accepts a list of {from, to, weight} tuples and adds each edge bidirectionally.

  ## Examples

      iex> graph = Algorithms.WeightedGraph.new()
      ...> |> Algorithms.WeightedGraph.add_undirected_edges([
      ...>   {"A", "B", 4},
      ...>   {"B", "C", 2},
      ...>   {"A", "C", 3}
      ...> ])
      iex> neighbors_a = Algorithms.WeightedGraph.neighbors(graph, "A")
      iex> Enum.sort(neighbors_a)
      [{"B", 4}, {"C", 3}]
  """
  def add_undirected_edges(graph, edges) when is_list(edges) do
    Enum.reduce(edges, graph, fn {from, to, weight}, acc ->
      add_undirected_edge(acc, from, to, weight)
    end)
  end

  @doc """
  Gets all neighbors of a node.
  """
  def neighbors(%__MODULE__{nodes: nodes}, node) do
    Map.get(nodes, node, [])
  end

  @doc """
  Gets all nodes in the graph.
  """
  def all_nodes(%__MODULE__{nodes: nodes}) do
    # Get all nodes that appear as keys or in neighbor lists
    keys = Map.keys(nodes)
    neighbors = nodes |> Map.values() |> List.flatten() |> Enum.map(&elem(&1, 0))
    (keys ++ neighbors) |> Enum.uniq()
  end
end
