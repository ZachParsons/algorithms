defmodule Algorithms.BinaryTree do
  @moduledoc false

  # TODO:
  # 1. list || traverse
  # 2. get || find || search.
  # 3. insert || create.
  # 4. update || move subtree.
  # 5. delete subtree.

  defmodule Node do
    @moduledoc false

    defstruct value: nil,
              left: nil,
              right: nil
  end

  # 1. List || traversal.

  # Preorder traversal (top -> bottom, left -> right)
  def preorder_traversal(nil), do: []

  def preorder_traversal(%Node{value: value, left: left, right: right}) do
    [value] ++ preorder_traversal(left) ++ preorder_traversal(right)
  end

  # Postorder traversal (bottom -> top, left -> right)
  def postorder_traversal(nil), do: []

  def postorder_traversal(%Node{value: value, left: left, right: right}) do
    postorder_traversal(left) ++ postorder_traversal(right) ++ [value]
  end

  # 2. Get || find.
  def find(value, %{value: n_value} = node) when n_value == value, do: node
  def find(_value, %{left: left, right: right}) when left == nil and right == nil, do: :not_found
  def find(value, %{value: n_value, left: left}) when value < n_value, do: find(value, left)
  def find(value, %{right: right}), do: find(value, right)
end
