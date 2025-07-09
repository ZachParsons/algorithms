defmodule Algorithms.BinarySearchTreeTest do
  use ExUnit.Case
  alias Algorithms.BinarySearchTree
  alias Algorithms.BinarySearchTree.Node

  describe "depth_first_preorder/1" do
    test "traverses depth-2 (three level) tree" do
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

      assert [8, 4, 2, 6, 12, 10, 14] == BinarySearchTree.depth_first_preorder(tree)
    end
  end

  describe "depth_first_inorder/1" do
    test "traverses depth-2 (three level) tree" do
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

      assert [2, 4, 6, 8, 10, 12, 14] == BinarySearchTree.depth_first_inorder(tree)
    end
  end

  describe "depth_first_postorder/1" do
    test "traverses depth-2 (three level) tree" do
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

      assert [2, 6, 4, 10, 14, 12, 8] == BinarySearchTree.depth_first_postorder(tree)
    end
  end

  describe "breadth_first/1" do
    test "traverses depth-2 (three level) tree" do
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

      assert [8, 4, 12, 2, 6, 10, 14] == BinarySearchTree.breadth_first(tree)
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
             } == BinarySearchTree.find(9, tree)
    end

    test "Not found", %{tree: tree} do
      assert :not_found == BinarySearchTree.find(2, tree)
    end
  end

  describe "insert/2" do
    test "inserts into empty tree" do
      assert %Node{value: 5, left: nil, right: nil} == BinarySearchTree.insert(5, nil)
    end

    test "inserts maintaining BST properties" do
      # Start with a simple tree
      tree = %Node{
        value: 8,
        left: %Node{value: 4, left: nil, right: nil},
        right: %Node{value: 12, left: nil, right: nil}
      }

      # Insert values that should go to different positions
      # Should go left of 4
      tree = BinarySearchTree.insert(2, tree)
      # Should go right of 4
      tree = BinarySearchTree.insert(6, tree)
      # Should go left of 12
      tree = BinarySearchTree.insert(10, tree)
      # Should go right of 12
      tree = BinarySearchTree.insert(14, tree)

      # Verify the structure through inorder traversal (should be sorted)
      assert [2, 4, 6, 8, 10, 12, 14] == BinarySearchTree.depth_first_inorder(tree)
    end

    test "inserts equal values to the left" do
      tree = %Node{value: 5, left: nil, right: nil}
      # Equal value should go left
      tree = BinarySearchTree.insert(5, tree)

      assert %Node{
               value: 5,
               left: %Node{value: 5, left: nil, right: nil},
               right: nil
             } == tree
    end
  end

  describe "update/3" do
    setup do
      [
        tree: %Node{
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
      ]
    end

    test "updates root node with new subtree", %{tree: tree} do
      new_subtree = %Node{
        value: 15,
        left: %Node{value: 13, left: nil, right: nil},
        right: %Node{value: 17, left: nil, right: nil}
      }

      {:ok, updated_tree} = BinarySearchTree.update(8, new_subtree, tree)

      # Root is replaced with new subtree, orphaned values (2,4,6,10,12,14) are re-inserted
      # So inorder: [2, 4, 6, 10, 12, 13, 14, 15, 17]
      assert [2, 4, 6, 10, 12, 13, 14, 15, 17] ==
               BinarySearchTree.depth_first_inorder(updated_tree)
    end

    test "updates leaf node with new subtree", %{tree: tree} do
      new_subtree = %Node{
        value: 3,
        left: %Node{value: 1, left: nil, right: nil},
        right: %Node{value: 5, left: nil, right: nil}
      }

      {:ok, updated_tree} = BinarySearchTree.update(2, new_subtree, tree)

      # Leaf node 2 is replaced with new subtree (3), orphaned value 2 is not re-inserted
      # So inorder: [1, 3, 4, 5, 6, 8, 10, 12, 14]
      assert [1, 3, 4, 5, 6, 8, 10, 12, 14] == BinarySearchTree.depth_first_inorder(updated_tree)
    end

    test "updates internal node with new subtree", %{tree: tree} do
      new_subtree = %Node{
        value: 5,
        left: %Node{value: 3, left: nil, right: nil},
        right: %Node{value: 7, left: nil, right: nil}
      }

      {:ok, updated_tree} = BinarySearchTree.update(4, new_subtree, tree)

      # Internal node 4 is replaced with new subtree (5), orphaned values (2,6) are re-inserted
      # So inorder: [2, 3, 5, 6, 7, 8, 10, 12, 14]
      assert [2, 3, 5, 6, 7, 8, 10, 12, 14] == BinarySearchTree.depth_first_inorder(updated_tree)
    end

    test "updates node in right subtree", %{tree: tree} do
      new_subtree = %Node{
        value: 11,
        left: %Node{value: 9, left: nil, right: nil},
        right: %Node{value: 13, left: nil, right: nil}
      }

      {:ok, updated_tree} = BinarySearchTree.update(10, new_subtree, tree)

      # Node 10 is replaced with new subtree (11), orphaned value 10 is not re-inserted
      # So inorder: [2, 4, 6, 8, 9, 11, 12, 13, 14]
      assert [2, 4, 6, 8, 9, 11, 12, 13, 14] == BinarySearchTree.depth_first_inorder(updated_tree)
    end

    test "updates with nil subtree (removes node)", %{tree: tree} do
      {:ok, updated_tree} = BinarySearchTree.update(4, nil, tree)

      # Node 4 is removed, orphaned values (2,6) are re-inserted
      # So inorder: [2, 6, 8, 10, 12, 14]
      assert [2, 6, 8, 10, 12, 14] == BinarySearchTree.depth_first_inorder(updated_tree)
    end

    test "updates with single node subtree", %{tree: tree} do
      new_subtree = %Node{value: 20, left: nil, right: nil}

      {:ok, updated_tree} = BinarySearchTree.update(6, new_subtree, tree)

      # Node 6 is replaced with new subtree (20), orphaned value 6 is not re-inserted
      # So inorder: [2, 4, 8, 10, 12, 14, 20]
      assert [2, 4, 8, 10, 12, 14, 20] == BinarySearchTree.depth_first_inorder(updated_tree)
    end

    test "returns error when target not found", %{tree: tree} do
      new_subtree = %Node{value: 99, left: nil, right: nil}

      assert {:error, :not_found} = BinarySearchTree.update(99, new_subtree, tree)
    end

    test "maintains BST properties after update", %{tree: tree} do
      # Create a complex subtree that maintains BST properties
      new_subtree = %Node{
        value: 5,
        left: %Node{
          value: 3,
          left: %Node{value: 1, left: nil, right: nil},
          right: %Node{value: 4, left: nil, right: nil}
        },
        right: %Node{
          value: 7,
          left: %Node{value: 6, left: nil, right: nil},
          right: %Node{value: 8, left: nil, right: nil}
        }
      }

      {:ok, updated_tree} = BinarySearchTree.update(4, new_subtree, tree)

      # Node 4 is replaced with new subtree, orphaned values (2,6) are re-inserted
      # So inorder: [1, 2, 3, 4, 5, 6, 6, 7, 8, 8, 10, 12, 14]
      inorder_result = BinarySearchTree.depth_first_inorder(updated_tree)
      assert inorder_result == Enum.sort(inorder_result)
      assert [1, 2, 3, 4, 5, 6, 6, 7, 8, 8, 10, 12, 14] == inorder_result
    end

    test "updates empty tree returns error" do
      new_subtree = %Node{value: 5, left: nil, right: nil}
      assert {:error, :not_found} = BinarySearchTree.update(5, new_subtree, nil)
    end
  end
end
