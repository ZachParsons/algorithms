defmodule Algorithms.Queue do
  @moduledoc """
    FIFO
  """

  def empty?([]), do: true
  def empty?(_), do: false

  def pop_rest([h | t]), do: {h, t}
  def popped([h | _t]), do: h

  def push(queue, element), do: queue ++ [element]
end
