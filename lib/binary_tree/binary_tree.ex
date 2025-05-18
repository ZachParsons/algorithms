defmodule Algorithms.BinaryTree do
  @moduledoc false

  # TODO:
  # [x] 1. list || traverse
  # [x] 2. get || find.
  # [ ] 3. insert || create.
  # [ ] 4. update || move subtree.
  # [ ] 5. delete subtree.

  defmodule Node do
    @moduledoc false

    defstruct value: nil,
              left: nil,
              right: nil
  end

  # 1. List || traversal.
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
end
