defmodule Algorithms.BinaryTree do
  # TODO:
  # 1. traverse
  # 2. insert
  # 3. delete
  # 4. move subtree

  defmodule BTNode do
    defstruct value: nil,
              left: nil,
              right: nil
  end

  def find(value, node) do
    if node.value == value do
      node
    else
      if node.left == nil && node.right == nil do
        :not_found
      else
        if value < node.value do
          find(value, node.left)
        else
          find(value, node.right)
        end
      end
    end
  end
end
