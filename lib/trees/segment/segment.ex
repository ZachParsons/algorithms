defmodule Algorithms.Trees.Segment do
  @moduledoc """
  Functional Segment Tree implementation that returns immutable tree structures.

  Each operation returns a new tree state that must be passed to subsequent operations.
  This follows pure functional programming principles with no side effects.

  Mnemonic:
  Data Flow: [integers] → {node_id => sum} → struct → integer

  Build: Recursive divide: leaf stores value, parent sums children

  Update: Path descent: if target ≤ mid go left, else right, bubble sums up

  Query: Range overlap: none=0, complete=node_value, partial=recurse both
  sides

  Decision Logic:
    Base: start == finish → leaf node (store/update value)
    Branch: idx ≤ mid → descend left subtree, else right
    Overlap: no_overlap=0, complete_overlap=cached, partial=sum_children

  Iteration Strategy: Log-height tree traversal, immutable map updates

  This captures the essence: segment trees partition ranges into a binary tree where each node caches the sum of its range, enabling O(log n) updates and queries through selective tree traversal based on range overlap patterns.
  """

  defstruct tree: %{}, n: 0, original: []

  @type t :: %__MODULE__{
          tree: %{integer() => integer()},
          n: integer(),
          original: [integer()]
        }

  @spec init([integer()]) :: t()
  def init(ints) do
    n = length(ints)
    tree = if n > 0, do: build_tree(ints, 1, 0, n - 1, %{}), else: %{}

    %__MODULE__{
      tree: tree,
      n: n,
      original: ints
    }
  end

  @spec update(t(), integer(), integer()) :: t()
  def update(%__MODULE__{tree: tree, n: n, original: original}, index, val) do
    new_original = List.replace_at(original, index, val)
    new_tree = if n > 0, do: update_tree(tree, 1, 0, n - 1, index, val), else: tree

    %__MODULE__{
      tree: new_tree,
      n: n,
      original: new_original
    }
  end

  @spec sum_range(t(), integer(), integer()) :: integer()
  def sum_range(%__MODULE__{tree: tree, n: n}, left, right) do
    if n == 0 do
      0
    else
      query_tree(tree, 1, 0, n - 1, left, right)
    end
  end

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

  defp query_tree(tree, node, start, finish, l, r) do
    cond do
      r < start or finish < l ->
        0

      l <= start and finish <= r ->
        Map.get(tree, node, 0)

      true ->
        mid = div(start + finish, 2)
        left_child = 2 * node
        right_child = 2 * node + 1

        left_sum = query_tree(tree, left_child, start, mid, l, r)
        right_sum = query_tree(tree, right_child, mid + 1, finish, l, r)
        left_sum + right_sum
    end
  end
end
