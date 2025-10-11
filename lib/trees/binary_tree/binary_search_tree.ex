defmodule Algorithms.Trees.BinarySearch do
  @moduledoc """
  A binary tree is a hierarchical data structure where each node has a maximum of two children (left and right). A binary search tree (BST) is a specific type of binary tree where the nodes are arranged in a way that allows for efficient searching. In a BST, the left child of a node always has a value less than or equal to the node's value, and the right child always has a value greater than or equal to the node's value.

  Mnemonic:
  Insert: Compare value, go left if smaller, right if larger, create node at nil
  Traverse: Visit nodes in order - preorder (root→left→right), inorder (left→root→right), postorder (left→right→root)
  Find: Compare value, go left if smaller, right if larger, return node or :not_found
  Delete: Find node, replace with nil (leaf), child (one child), or inorder successor (two children)
  """

  defmodule Node do
    @moduledoc false

    defstruct value: nil,
              left: nil,
              right: nil
  end

  # 1. List || traversal.
  # The difference between traversal and list: Traversal is about the process of visiting nodes, while listing is about the final arrangement of elements. In many implementations, they're combined because we often want both the traversal order and the resulting list.

  # The breadth-first and depth-first functions differ significantly because they use fundamentally different approaches to traverse the tree:
  #   The key differences are:
  #   State Management:
  #     DFS: Uses implicit state through recursion
  #     BFS: Uses explicit state through queue
  #   Memory Structure:
  #     DFS: Stack-based (LIFO - Last In, First Out)
  #     BFS: Queue-based (FIFO - First In, First Out)
  #   Implementation Complexity:
  #     DFS: Simpler to implement due to natural recursion
  #     BFS: More complex due to need for explicit queue management
  #   Memory Usage Pattern:
  #     DFS: Memory usage depends on tree height
  #     BFS: Memory usage depends on tree width

  # Preorder traversal (top -> bottom, left -> right)
  def depth_first_preorder(nil), do: []

  def depth_first_preorder(%Node{value: value, left: left, right: right}) do
    [value] ++ depth_first_preorder(left) ++ depth_first_preorder(right)
  end

  # Inorder traversal (left -> root -> right)
  def depth_first_inorder(nil), do: []

  def depth_first_inorder(%Node{value: value, left: left, right: right}) do
    depth_first_inorder(left) ++ [value] ++ depth_first_inorder(right)
  end

  # Postorder traversal (bottom -> top, left -> right)
  def depth_first_postorder(nil), do: []

  def depth_first_postorder(%Node{value: value, left: left, right: right}) do
    depth_first_postorder(left) ++ depth_first_postorder(right) ++ [value]
  end

  # Breadth-first traversal (left -> right, top -> bottom level by level)
  def breadth_first_level_order(nil), do: []

  def breadth_first_level_order(root) do
    breadth_first_level_order([root], [])
  end

  defp breadth_first_level_order([], result), do: Enum.reverse(result)

  defp breadth_first_level_order([nil | rest], result),
    do: breadth_first_level_order(rest, result)

  defp breadth_first_level_order([%Node{value: value, left: left, right: right} | rest], result) do
    breadth_first_level_order(rest ++ [left, right], [value | result])
  end

  # 2. Get || find.
  def find(value, %{value: n_value} = node) when n_value == value, do: node
  def find(_value, %{left: left, right: right}) when left == nil and right == nil, do: :not_found
  def find(value, %{value: n_value, left: left}) when value < n_value, do: find(value, left)
  def find(value, %{right: right}), do: find(value, right)

  # 3. Insert || create.
  def insert(value, nil), do: %Node{value: value, left: nil, right: nil}

  def insert(value, %Node{value: n_value} = node) when value <= n_value do
    %{node | left: insert(value, node.left)}
  end

  def insert(value, %Node{value: n_value} = node) when value > n_value do
    %{node | right: insert(value, node.right)}
  end

  # 4. Update || move subtree.
  # Alternative implementation that maintains BST properties by removing and re-inserting
  @doc """
  Updates a node in the tree by removing the target node and inserting the new subtree
  at the appropriate position to maintain BST properties. Orphaned children are re-inserted.
  Returns {:ok, updated_tree} if successful, {:error, :not_found} if target not found.
  """
  def update(target_value, new_subtree, tree) do
    case remove_node_and_get_children(target_value, tree) do
      {:ok, tree_without_node, orphaned_children} ->
        # Insert the new subtree at the appropriate position
        updated_tree = insert_subtree(new_subtree, tree_without_node)
        # Re-insert only unique values from orphaned children
        final_tree = reinsert_unique_orphans(orphaned_children, updated_tree, new_subtree)
        {:ok, final_tree}

      :not_found ->
        {:error, :not_found}
    end
  end

  # Remove a node and return its orphaned children
  defp remove_node_and_get_children(_target_value, nil), do: :not_found

  defp remove_node_and_get_children(target_value, %Node{value: value, left: left, right: right})
       when value == target_value do
    # Found the target node, collect its children and remove it
    orphaned_children = collect_children(left, right)

    case {left, right} do
      # Leaf node
      {nil, nil} ->
        {:ok, nil, orphaned_children}

      # Only right child
      {nil, right} ->
        {:ok, right, orphaned_children}

      # Only left child
      {left, nil} ->
        {:ok, left, orphaned_children}

      {left, right} ->
        # Node has both children, find the smallest value in right subtree
        smallest = find_smallest(right)
        # Remove the smallest value from right subtree
        {:ok, new_right, _} = remove_node_and_get_children(smallest, right)
        # Create new node with smallest value as root
        {:ok, %Node{value: smallest, left: left, right: new_right}, orphaned_children}
    end
  end

  defp remove_node_and_get_children(
         target_value,
         %Node{value: value, left: left, right: _right} = node
       )
       when target_value < value do
    case remove_node_and_get_children(target_value, left) do
      {:ok, new_left, orphaned_children} -> {:ok, %{node | left: new_left}, orphaned_children}
      :not_found -> :not_found
    end
  end

  defp remove_node_and_get_children(
         target_value,
         %Node{value: value, left: _left, right: right} = node
       )
       when target_value > value do
    case remove_node_and_get_children(target_value, right) do
      {:ok, new_right, orphaned_children} -> {:ok, %{node | right: new_right}, orphaned_children}
      :not_found -> :not_found
    end
  end

  # Collect all children from a subtree into a list of subtrees
  defp collect_children(nil, nil), do: []
  defp collect_children(left, nil), do: [left]
  defp collect_children(nil, right), do: [right]
  defp collect_children(left, right), do: [left, right]

  # Helper to collect all values in a subtree as a MapSet
  defp collect_value_set(nil), do: MapSet.new()

  defp collect_value_set(%Node{value: value, left: left, right: right}) do
    MapSet.put(MapSet.union(collect_value_set(left), collect_value_set(right)), value)
  end

  # Insert all unique values from orphaned subtrees that are not present in the updated tree
  defp reinsert_unique_orphans(orphaned_subtrees, tree, _new_subtree) do
    existing_values = collect_value_set(tree)
    insert_orphaned_values(orphaned_subtrees, tree, existing_values)
  end

  defp insert_orphaned_values([], tree, _new_values), do: tree

  defp insert_orphaned_values([nil | rest], tree, new_values),
    do: insert_orphaned_values(rest, tree, new_values)

  defp insert_orphaned_values([%Node{} = subtree | rest], tree, new_values) do
    {tree, new_values} = insert_subtree_unique(subtree, tree, new_values)
    insert_orphaned_values(rest, tree, new_values)
  end

  # Insert a subtree, but only values not already in new_values
  defp insert_subtree_unique(nil, tree, new_values), do: {tree, new_values}

  defp insert_subtree_unique(%Node{value: value, left: left, right: right}, tree, new_values) do
    if MapSet.member?(new_values, value) do
      # Skip duplicate
      {tree, new_values}
    else
      tree = insert(value, tree)
      new_values = MapSet.put(new_values, value)
      {tree, new_values} = insert_subtree_unique(left, tree, new_values)
      insert_subtree_unique(right, tree, new_values)
    end
  end

  # Find the smallest value in a subtree
  defp find_smallest(%Node{value: value, left: nil}), do: value
  defp find_smallest(%Node{left: left}), do: find_smallest(left)

  # Insert a subtree at the appropriate position to maintain BST properties
  defp insert_subtree(nil, tree), do: tree

  defp insert_subtree(%Node{value: value, left: left, right: right}, tree) do
    tree = insert(value, tree)
    tree = insert_subtree(left, tree)
    insert_subtree(right, tree)
  end

  # 5. Delete || remove.
  @doc """
  Deletes a node with the given value from the binary search tree.
  Returns {:ok, updated_tree} if successful, {:error, :not_found} if value not found.

  The deletion handles three cases:
  1. Leaf node: Simply remove it
  2. Node with one child: Replace with the child
  3. Node with two children: Replace with the smallest value from the right subtree
  """
  def delete(value, tree) do
    case delete_node(value, tree) do
      {:ok, updated_tree} -> {:ok, updated_tree}
      :not_found -> {:error, :not_found}
    end
  end

  defp delete_node(_value, nil), do: :not_found

  defp delete_node(value, %Node{value: node_value, left: left, right: right})
       when value == node_value do
    case {left, right} do
      # Case 1: Leaf node - simply remove it
      {nil, nil} ->
        {:ok, nil}

      # Case 2: Node with only right child
      {nil, right} ->
        {:ok, right}

      # Case 2: Node with only left child
      {left, nil} ->
        {:ok, left}

      # Case 3: Node with both children
      {left, right} ->
        # Find the smallest value in the right subtree (inorder successor)
        smallest = find_smallest(right)
        # Remove the smallest value from the right subtree
        {:ok, new_right} = delete_node(smallest, right)
        # Create new node with smallest value as root
        {:ok, %Node{value: smallest, left: left, right: new_right}}
    end
  end

  defp delete_node(value, %Node{value: node_value, left: left, right: _right} = node)
       when value < node_value do
    case delete_node(value, left) do
      {:ok, new_left} -> {:ok, %{node | left: new_left}}
      :not_found -> :not_found
    end
  end

  defp delete_node(value, %Node{value: node_value, left: _left, right: right} = node)
       when value > node_value do
    case delete_node(value, right) do
      {:ok, new_right} -> {:ok, %{node | right: new_right}}
      :not_found -> :not_found
    end
  end
end
