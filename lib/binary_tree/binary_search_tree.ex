defmodule Algorithms.BinarySearchTree do
  # TODO:
  # 1. traverse
  # 2. insert
  # 3. delete
  # 4. move subtree



  # def find(value, node) do
  #   if node.value == value do
  #     node
  #   else
  #     if node.left == nil && node.right == nil do
  #       :not_found
  #     else
  #       if value < node.value do
  #         find(value, node.left)
  #       else
  #         find(value, node.right)
  #       end
  #     end
  #   end
  # end

  def find(value, %{value: n_value} = node) when n_value == value, do: node
  def find(_value, %{left: left, right: right}) when left == nil and right == nil, do: :not_found
  def find(value, %{value: n_value, left: left}) when value < n_value, do: find(value, left)
  def find(value, %{right: right}), do: find(value, right)
end
