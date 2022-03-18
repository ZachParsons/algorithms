defmodule Algorithms.QueueTest do
  use ExUnit.Case
  alias Algorithms.Queue

  describe "enqueue/2" do
    test "empty queue" do
      queue = []
      result = Queue.enqueue(queue, 1)
      assert [1] == result
    end

    test "non-empty queue" do
      queue = [1, 2]
      result = Queue.enqueue(queue, 3)
      assert [1, 2, 3] == result
    end
  end

  describe "dequeue/1" do
    test "returns dequeued & queue" do
      queue = [1, 2, 3]
      result = Queue.dequeue(queue)
      assert {1, [2, 3]} == result
    end

    test "returns dequeued" do
      queue = [1, 2, 3]
      result = Queue.dequeued(queue)
      assert 1 == result
    end
  end
end
