defmodule Algorithms.StackTest do
  use ExUnit.Case
  alias Algorithms.Stack

  test "pop_reduce/1" do
    stack = [1, 2, 3]
    result = Stack.pop_reduce(stack)
    assert 3 = result
  end

  test "pop_bif/1" do
    stack = [1, 2, 3]
    result = Stack.pop_bif(stack)
    assert {3, [1, 2]} = result
  end
end
