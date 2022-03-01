defmodule Algorithms.BinarySearchTree do
  # TODO:
  # 1. traverse
  # 2. insert
  # 3. delete
  # 4. move subtree

  defmodule BSTNode do
    defstruct value: nil,
              left: nil,
              right: nil
  end

  # def get(value, node) do
  #   if node.value == value do
  #     node
  #   else
  #     if node.left == nil && node.right == nil do
  #       :not_found
  #     else
  #       if value < node.value do
  #         get(value, node.left)
  #       else
  #         get(value, node.right)
  #       end
  #     end
  #   end
  # end

  def get(value, %{value: n_value} = node) when n_value == value, do: node
  def get(_value, %{left: left, right: right}) when left == nil and right == nil, do: :not_found
  def get(value, %{value: n_value, left: left}) when value < n_value, do: get(value, left)
  def get(value, %{right: right}), do: get(value, right)
end
