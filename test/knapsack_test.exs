defmodule Algorithms.KnapsackTest do
  use ExUnit.Case
  alias Algorithms.Knapsack.BranchAndBound, as: BB
  alias Algorithms.Knapsack.DP

  describe "branch_and_bound/2" do
    test "runs basic knapsack problem" do
      items = [
        %{value: 60, weight: 10},
        %{value: 100, weight: 20},
        %{value: 120, weight: 30}
      ]

      capacity = 50

      expected_result = {
        # optimal value
        220,
        # selected items (indices)
        [
          # item with value 100, weight 20
          1,
          # item with value 120, weight 30
          2
        ]
      }

      assert expected_result == BB.run(items, capacity)
      assert expected_result == DP.run(items, capacity)
    end

    test "handles empty item list" do
      expected_result = {0, []}
      assert expected_result == BB.run([], 50)
      assert expected_result == DP.run([], 50)
    end

    test "handles zero capacity" do
      items = [
        %{value: 60, weight: 10},
        %{value: 100, weight: 20}
      ]

      expected_result = {0, []}
      assert expected_result == BB.run(items, 0)
      assert expected_result == DP.run(items, 0)
    end

    test "runs problem with items of equal value but different weights" do
      items = [
        %{value: 100, weight: 20},
        %{value: 100, weight: 10},
        %{value: 100, weight: 15}
      ]

      capacity = 30

      assert {200, bb_indices} = BB.run(items, capacity)
      assert {200, dp_indices} = DP.run(items, capacity)

      # # Verify both solutions are valid (different algorithms may choose different optimal solutions)
      # # Both should be valid optimal solutions (could be [0,1] or [1,2])
      valid_solutions = [[0, 1], [1, 2]]
      assert bb_indices in valid_solutions
      assert dp_indices in valid_solutions
    end

    test "handles larger problem efficiently" do
      items = [
        %{value: 60, weight: 10},
        %{value: 100, weight: 20},
        %{value: 120, weight: 30},
        %{value: 80, weight: 15},
        %{value: 200, weight: 40},
        %{value: 160, weight: 25},
        %{value: 90, weight: 18}
      ]

      capacity = 80

      expected_result = {
        # optimal value
        440,
        # selected items (indices)
        [
          # item with value 80, weight 15
          3,
          # item with value 200, weight 40
          4,
          # item with value 160, weight 25
          5
        ]
      }

      assert expected_result == BB.run(items, capacity)
      assert expected_result == DP.run(items, capacity)
    end

    test "all items exceed capacity individually" do
      items = [
        %{value: 100, weight: 30},
        %{value: 200, weight: 40},
        %{value: 300, weight: 50}
      ]

      capacity = 20
      expected_result = {0, []}
      assert expected_result == BB.run(items, capacity)
      assert expected_result == DP.run(items, capacity)
    end
  end
end
