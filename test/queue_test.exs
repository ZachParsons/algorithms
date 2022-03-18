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

  describe "erlang queue" do
    setup do
      queue0 = :queue.new()
      queue1 = :queue.in(1, queue0)
      queue2 = :queue.in(2, queue1)

      [empty_queue: queue0, queue: queue2]
    end

    test "erl_is_empty?/1", %{empty_queue: empty_queue} do
      result = Queue.erl_is_empty?(empty_queue)
      assert true == result
    end

    test "erl_enqueue/2", %{empty_queue: empty_queue} do
      result = Queue.erl_enqueue(1, empty_queue)
      assert {[1], []} == result
    end

    test "erl_dequeue/1", %{queue: queue} do
      result = Queue.erl_dequeue(queue)
      assert {{:value, 1}, {[], [2]}} == result
    end
  end
end
