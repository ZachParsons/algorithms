defmodule Algorithms.BinarySearchTreeTest do
  use ExUnit.Case
  alias Algorithms.BinarySearchTree
  alias Algorithms.BinarySearchTree.BSTNode

  describe "find/2" do
    setup do
      [
        tree: %BSTNode{
          value: 6,
          left: %BSTNode{
            value: 5,
            left: %BSTNode{
              value: 4,
              left: nil,
              right: nil
            },
            right: nil
          },
          right: %BSTNode{
            value: 9,
            left: %BSTNode{
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
      assert %BSTNode{
               value: 9,
               left: %BSTNode{
                 left: nil,
                 right: nil,
                 value: 7
               },
               right: nil
             } == BinarySearchTree.get(9, tree)
    end

    test "Not found", %{tree: tree} do
      assert :not_found == BinarySearchTree.get(2, tree)
    end
  end
end
