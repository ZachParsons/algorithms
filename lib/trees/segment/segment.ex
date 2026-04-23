defmodule Algorithms.Trees.Segment do
  @moduledoc """
  Functional Segment Tree implementation that returns immutable tree structures.

  Each operation returns a new tree state that must be passed to subsequent operations.
  This follows pure functional programming principles with no side effects.

  Triadic Pseudocode Protocol:
    ALGO SegmentTree(arr)  # Build/Query/Update
    ├── DATA: IN: arr[n] → OUT: tree[4n]  # Range queries
    ├── ENUMERATE: RECURSE build(1, 0, n-1)
    │   └── tree[node] ← combine(left_child, right_child)
    └── CONDITIONAL (Query l..r):
        ├── IF fully covered → RETURN tree[node]
        ├── IF no overlap → ∞/0/neutral
        └── ELSE → Query left + Query right
        # Update similar: RECURSE to leaf, bubble up combines

  Mnemonic:
  Build: Split array recursively, store values at leaves, bubble sums to parents
  Store: Map node_id→sum, track original array for updates
  Query: Check overlap - none=0, complete=cached, partial=recurse left+right
  Update: Find leaf by index, replace value, bubble new sums up path
  """

  defstruct tree: %{}, el_count: 0, source: []

  @type t :: %__MODULE__{
          tree: %{integer() => integer()},
          el_count: integer(),
          source: [integer()]
        }

  @spec init([integer()]) :: t()
  def init(ints) do
    el_count = length(ints)
    tree = if el_count > 0, do: build_tree(ints, 1, 0, el_count - 1, %{}), else: %{}

    %__MODULE__{
      tree: tree,
      el_count: el_count,
      source: ints
    }
  end

  # CREATE
  # Private helper functions for functional implementation
  defp build_tree(ints, node, start, finish, tree) when start == finish do
    value = Enum.at(ints, start)
    Map.put(tree, node, value)
  end

  defp build_tree(ints, node, start, finish, tree) do
    mid = div(start + finish, 2)
    left_child = 2 * node
    right_child = 2 * node + 1

    # Build left subtree
    tree_with_left = build_tree(ints, left_child, start, mid, tree)
    # Build right subtree
    tree_with_both = build_tree(ints, right_child, mid + 1, finish, tree_with_left)

    # Set current node value as sum of children
    left_val = Map.get(tree_with_both, left_child, 0)
    right_val = Map.get(tree_with_both, right_child, 0)
    Map.put(tree_with_both, node, left_val + right_val)
  end

  # READ
  @spec sum_range(t(), integer(), integer()) :: integer()
  def sum_range(%__MODULE__{tree: _tree, el_count: 0}, _left, _right), do: 0

  def sum_range(%__MODULE__{tree: tree, el_count: el_count}, left, right),
    do: query_tree(tree, 1, 0, el_count - 1, left, right)

  defp query_tree(_tree, _node, start, finish, l, r) when r < start or finish < l, do: 0

  defp query_tree(tree, node, start, finish, l, r) when l <= start and finish <= r,
    do: Map.get(tree, node, 0)

  defp query_tree(tree, node, start, finish, l, r) do
    mid = div(start + finish, 2)
    left_child = 2 * node
    right_child = 2 * node + 1

    left_sum = query_tree(tree, left_child, start, mid, l, r)
    right_sum = query_tree(tree, right_child, mid + 1, finish, l, r)
    left_sum + right_sum
  end

  # UPDATE
  @spec update(t(), integer(), integer()) :: t()
  def update(
        %__MODULE__{tree: tree, el_count: el_count, source: source},
        index,
        val
      ) do
    new_source = List.replace_at(source, index, val)

    new_tree =
      if el_count > 0, do: update_tree(tree, 1, 0, el_count - 1, index, val), else: tree

    %__MODULE__{
      tree: new_tree,
      el_count: el_count,
      source: new_source
    }
  end

  defp update_tree(tree, node, start, finish, _idx, val) when start == finish do
    Map.put(tree, node, val)
  end

  defp update_tree(tree, node, start, finish, idx, val) do
    mid = div(start + finish, 2)
    left_child = 2 * node
    right_child = 2 * node + 1

    new_tree =
      if idx <= mid do
        update_tree(tree, left_child, start, mid, idx, val)
      else
        update_tree(tree, right_child, mid + 1, finish, idx, val)
      end

    # Update current node with new sum
    left_val = Map.get(new_tree, left_child, 0)
    right_val = Map.get(new_tree, right_child, 0)
    Map.put(new_tree, node, left_val + right_val)
  end
end
