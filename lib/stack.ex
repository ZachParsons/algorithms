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

  def bif_pop_at(stack), do: List.pop_at(stack, -1)
  def bif_last(stack), do: List.last(stack)

  def pop_recursive([h | _t] = stack) when length(stack) == 1, do: h
  def pop_recursive([_h | t] = stack) when length(stack) > 1, do: pop_recursive(t)

  def push(stack, element), do: stack ++ [element]
end
