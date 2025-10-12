defmodule Algorithms.StackTest do
  use ExUnit.Case
  alias Algorithms.Collections.Stack

  describe "push/2" do
    test "inserts into empty stack" do
      stack = []
      result = Stack.push(stack, 1)
      assert [1] = result
    end

    test "appends non-empty stack" do
      stack = [1, 2]
      result = Stack.push(stack, 3)
      assert [1, 2, 3] = result
    end
  end

  describe "pop operation" do
    test "pop_reduce/1" do
      stack = [1, 2, 3]
      result = Stack.pop_reduce(stack)
      assert 3 = result
    end

    test "bif_pop_at/1" do
      stack = [1, 2, 3]
      result = Stack.bif_pop_at(stack)
      assert {3, [1, 2]} = result
    end

    test "bif_last/1" do
      stack = [1, 2, 3]
      result = Stack.bif_last(stack)
      assert 3 = result
    end

    test "pop_recursive/1" do
      stack = [1, 2, 3]
      result = Stack.pop_recursive(stack)
      assert 3 = result
    end
  end
end
