defmodule Algorithms.FibonacciTest do
  use ExUnit.Case
  alias Algorithms.Fibonacci

  test "0..19" do
    assert Enum.map(
             0..19,
             &Fibonacci.run/1
           ) == [
             1,
             1,
             2,
             3,
             5,
             8,
             13,
             21,
             34,
             55,
             89,
             144,
             233,
             377,
             610,
             987,
             1597,
             2584,
             4181,
             6765
           ]
  end

  test "invalid" do
    result =
      [
        "a",
        :a,
        1.5
      ]
      |> Enum.map(&Fibonacci.run/1)

    assert Enum.all?(
             result,
             &(&1 == "invalid input")
           )
  end
end
