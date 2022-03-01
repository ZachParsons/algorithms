defmodule Algorithms.Stack do
  @moduledoc """
    LIFO
  """

  def empty?([]), do: true
  def empty?(_), do: false

  def pop_reduce([_h | t] = stack) do
    # {h, t}
    Enum.reduce(stack, [], fn(element, acc)->
      if t == [], do: acc, else: element
    end)
  end

  def pop_bif(stack), do: List.pop_at(stack, -1)

  def push(stack, element), do: stack ++ [element]
end

