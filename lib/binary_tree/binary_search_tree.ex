defmodule Algorithms.BinarySearchTree do
  @moduledoc """
  A binary tree is a hierarchical data structure where each node has a maximum of two children (left and right). A binary search tree (BST) is a specific type of binary tree where the nodes are arranged in a way that allows for efficient searching. In a BST, the left child of a node always has a value less than or equal to the node's value, and the right child always has a value greater than or equal to the node's value.
  """

  # TODO:
  # [x] 1. list || traverse.
  # [x] 2. get || find.
  # [x] 3. insert || create.
  # [ ] 4. update || move subtree.
  # [ ] 5. delete subtree.

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
  def breadth_first(nil), do: []

  def breadth_first(root) do
    breadth_first([root], [])
  end

  defp breadth_first([], result), do: Enum.reverse(result)
  defp breadth_first([nil | rest], result), do: breadth_first(rest, result)

  defp breadth_first([%Node{value: value, left: left, right: right} | rest], result) do
    breadth_first(rest ++ [left, right], [value | result])
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
end
