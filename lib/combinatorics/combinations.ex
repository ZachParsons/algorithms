defmodule Algorithms.Combinatorics.Combinations do
  @moduledoc false
  def run(elements, size)
      when is_list(elements) and
             is_integer(size) and
             length(elements) >= size,
      do: do_run(elements, size)

  def run(_, _), do: "invalid input"

  defp do_run(_elements, 0), do: [[]]
  defp do_run(elements = [], _size), do: elements

  defp do_run([head | tail], size) do
    Enum.map(do_run(tail, size - 1), &[head | &1]) ++
      do_run(tail, size)
  end
end
