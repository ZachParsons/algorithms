defmodule Algorithms.BinaryTreeTest do
  use ExUnit.Case
  alias Algorithms.BinaryTree
  alias Algorithms.BinaryTree.Node

  describe "preorder_traversal/1" do
    test "traverses three-level tree" do
      tree = %Node{
        value: 8,
        left: %Node{
          value: 4,
          left: %Node{value: 2, left: nil, right: nil},
          right: %Node{value: 6, left: nil, right: nil}
        },
        right: %Node{
          value: 12,
          left: %Node{value: 10, left: nil, right: nil},
          right: %Node{value: 14, left: nil, right: nil}
        }
      }

      assert [8, 4, 2, 6, 12, 10, 14] == BinaryTree.preorder_traversal(tree)
    end
  end

  describe "inorder_traversal/1" do
    test "traverses three-level tree" do
      tree = %Node{
        value: 8,
        left: %Node{
          value: 4,
          left: %Node{value: 2, left: nil, right: nil},
          right: %Node{value: 6, left: nil, right: nil}
        },
        right: %Node{
          value: 12,
          left: %Node{value: 10, left: nil, right: nil},
          right: %Node{value: 14, left: nil, right: nil}
        }
      }

      assert [2, 4, 6, 8, 10, 12, 14] == BinaryTree.inorder_traversal(tree)
    end
  end

  describe "postorder_traversal/1" do
    test "traverses complex tree" do
      tree = %Node{
        value: 8,
        left: %Node{
          value: 4,
          left: %Node{value: 2, left: nil, right: nil},
          right: %Node{value: 6, left: nil, right: nil}
        },
        right: %Node{
          value: 12,
          left: %Node{value: 10, left: nil, right: nil},
          right: %Node{value: 14, left: nil, right: nil}
        }
      }

      assert [2, 6, 4, 10, 14, 12, 8] == BinaryTree.postorder_traversal(tree)
    end
  end

  describe "breadth_first_traversal/1" do
    test "traverses three-level tree" do
      tree = %Node{
        value: 8,
        left: %Node{
          value: 4,
          left: %Node{value: 2, left: nil, right: nil},
          right: %Node{value: 6, left: nil, right: nil}
        },
        right: %Node{
          value: 12,
          left: %Node{value: 10, left: nil, right: nil},
          right: %Node{value: 14, left: nil, right: nil}
        }
      }

      assert [8, 4, 12, 2, 6, 10, 14] == BinaryTree.breadth_first_traversal(tree)
    end
  end

  describe "find/2" do
    setup do
      [
        tree: %Node{
          value: 6,
          left: %Node{
            value: 5,
            left: %Node{value: 4, left: nil, right: nil},
            right: nil
          },
          right: %Node{
            value: 9,
            left: %Node{value: 7, left: nil, right: nil},
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
             } == BinaryTree.find(9, tree)
    end

    test "Not found", %{tree: tree} do
      assert :not_found == BinaryTree.find(2, tree)
    end
  end
end
