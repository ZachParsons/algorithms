defmodule Algorithms.Queue do
  @moduledoc """
    FIFO
  """

  def empty?([]), do: true
  def empty?(_), do: false

  def pop([h | t]), do: {h, t}

  def push(queue, element), do: queue ++ [element]
end
