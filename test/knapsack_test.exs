defmodule Algorithms.KnapsackTest do
  use ExUnit.Case
  alias Algorithms.Knapsack

  describe "branch_and_bound/2" do
    test "solves basic knapsack problem" do
      items = [
        %{value: 60, weight: 10},
        %{value: 100, weight: 20},
        %{value: 120, weight: 30}
      ]

      capacity = 50

      assert Knapsack.branch_and_bound(items, capacity) == {
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
    end

    test "handles empty item list" do
      assert Knapsack.branch_and_bound([], 50) == {0, []}
    end

    test "handles zero capacity" do
      items = [
        %{value: 60, weight: 10},
        %{value: 100, weight: 20}
      ]

      assert Knapsack.branch_and_bound(items, 0) == {0, []}
    end

    test "solves problem with items of equal value but different weights" do
      items = [
        %{value: 100, weight: 20},
        %{value: 100, weight: 10},
        %{value: 100, weight: 15}
      ]

      capacity = 30

      assert Knapsack.branch_and_bound(items, capacity) == {
               # optimal value
               200,
               # selected items (indices)
               [
                 # item with value 100, weight 10
                 1,
                 # item with value 100, weight 15
                 2
               ]
             }
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

      assert Knapsack.branch_and_bound(items, capacity) == {
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
    end

    test "all items exceed capacity individually" do
      items = [
        %{value: 100, weight: 30},
        %{value: 200, weight: 40},
        %{value: 300, weight: 50}
      ]

      capacity = 20

      assert Knapsack.branch_and_bound(items, capacity) == {0, []}
    end
  end
end
