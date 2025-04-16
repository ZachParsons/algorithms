defmodule Algorithms.BinarySearchTreeTest do
  use ExUnit.Case
  alias Algorithms.BinarySearchTree
  alias Algorithms.BinarySearchTree.Node

  describe "find/2" do
    setup do
      [
        tree: %Node{
          value: 6,
          left: %Node{
            value: 5,
            left: %Node{
              value: 4,
              left: nil,
              right: nil
            },
            right: nil
          },
          right: %Node{
            value: 9,
            left: %Node{
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
      assert %Node{
               value: 9,
               left: %Node{
                 left: nil,
                 right: nil,
                 value: 7
               },
               right: nil
             } == BinarySearchTree.find(9, tree)
    end

    test "Not found", %{tree: tree} do
      assert :not_found == BinarySearchTree.find(2, tree)
    end
  end
end
