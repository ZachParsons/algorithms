defmodule Algorithms.Combinations do
  def run(elements, size)
      when not is_list(elements) or not is_integer(size) do
    "invalid input"
  end

  def run(_elements, 0), do: [[]]
  def run(elements = [], _size), do: elements

  def run([head | tail], size) do
    Enum.map(run(tail, size - 1), &[head | &1]) ++
      run(tail, size)
  end
end
