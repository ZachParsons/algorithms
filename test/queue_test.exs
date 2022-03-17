defmodule Algorithms.QueueTest do
  use ExUnit.Case
  alias Algorithms.Queue

  describe "push/2" do
    test "empty queue" do
      queue = []
      result = Queue.push(queue, 1)
      assert [1] == result
    end

    test "non-empty queue" do
      queue = [1, 2]
      result = Queue.push(queue, 3)
      assert [1, 2, 3] == result
    end
  end

  describe "pop/1" do
    test "returns popped & rest" do
      queue = [1, 2, 3]
      result = Queue.pop_rest(queue)
      assert {1, [2, 3]} == result
    end

    test " returns popped" do
      queue = [1, 2, 3]
      result = Queue.popped(queue)
      assert 1 == result
    end
  end
end
