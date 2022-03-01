defmodule Algorithms.StackTest do
  use ExUnit.Case
  alias Algorithms.Stack

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
