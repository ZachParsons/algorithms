defmodule Algorithms.FizzBuzz do
  def run(n) when not is_integer(n) or n <= 0, do: "Invalid input"
  def run(n) when rem(n, 3) == 0 and rem(n, 5) == 0, do: "FizzBuzz"
  def run(n) when rem(n, 3) == 0, do: "Fizz"
  def run(n) when rem(n, 5) == 0, do: "Buzz"
  def run(n), do: n
end
