defmodule Algorithms.FizzBuzzTest do
  use ExUnit.Case
  alias Algorithms.FizzBuzz

  test "FizzBuzz success" do
    assert "Fizz" == FizzBuzz.run(3)
    assert "Buzz" == FizzBuzz.run(5)
    assert "FizzBuzz" == FizzBuzz.run(15)
    assert 16 == FizzBuzz.run(16)
  end

  test "FizzBuzz error" do
    assert "Invalid input" == FizzBuzz.run(-1)
    assert "Invalid input" == FizzBuzz.run("fail")
    assert "Invalid input" == FizzBuzz.run(0)
  end
end
