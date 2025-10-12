defmodule Algorithms.Collections.Queue do
  @moduledoc """
    FIFO
  """

  def empty?([]), do: true
  def empty?(_), do: false

  def enqueue(queue, element), do: queue ++ [element]

  def dequeue([h | t]), do: {h, t}

  def dequeued([h | _t]), do: h

  def erl_is_empty?(queue) do
    :queue.is_empty(queue)
  end

  def erl_enqueue(element, queue) do
    :queue.in(element, queue)
  end

  def erl_dequeue(queue) do
    :queue.out(queue)
  end
end
