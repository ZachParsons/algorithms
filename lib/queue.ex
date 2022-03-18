defmodule Algorithms.Queue do
  @moduledoc """
    FIFO
  """

  def empty?([]), do: true
  def empty?(_), do: false

  def dequeue([h | t]), do: {h, t}
  def dequeued([h | _t]), do: h

  def enqueue(queue, element), do: queue ++ [element]
end
