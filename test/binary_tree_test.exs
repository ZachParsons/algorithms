defmodule Algorithms.BinaryTreeTest do
  use ExUnit.Case
  alias Algorithms.BinaryTree
  alias Algorithms.BinaryTree.BTNode

  describe "find/2" do
    setup do
      [
        tree: %BTNode{
          value: 6,
          left: %BTNode{
            value: 5,
            left: %BTNode{
              value: 4,
              left: nil,
              right: nil
            },
            right: nil
          },
          right: %BTNode{
            value: 9,
            left: %BTNode{
              value: 7,
              left: nil,
              right: nil
            },
            right: nil
          }
        }
      ]
    end

    test "Found", %{tree: tree} do
      assert %BTNode{
               value: 9,
               left: %BTNode{
                 left: nil,
                 right: nil,
                 value: 7
               },
               right: nil
             } == BinaryTree.find(9, tree)
    end

    test "Not found", %{tree: tree} do
      assert :not_found == BinaryTree.find(2, tree)
    end
  end
end
