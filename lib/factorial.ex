defmodule Algorithms.Factorial do
  @moduledoc false
  # Enumeration reduce
  def run(0), do: 1

  def run(i)
      when is_integer(i) and i > 0 do
    Enum.reduce(1..i, 1, &*/2)
  end

  def run(_), do: "invalid input"

  # Tail recursive
  def run_tr(i, acc \\ 1)
  def run_tr(0, acc), do: acc

  def run_tr(i, acc) when is_integer(i) and i > 0 do
    run_tr(i - 1, acc * i)
  end

  def run_tr(_, _), do: "invalid input"
end
