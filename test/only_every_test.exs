defmodule Algorithms.OnlyEveryTest do
  use ExUnit.Case
  alias Algorithms.OnlyEvery

  test "success: evens" do
    assert [2, 4, 6] == OnlyEvery.run(2..10, 3, 2)
    assert [2, 4, 6, 8] == OnlyEvery.run(2..10, 4, 2)
    assert [2, 4, 6, 8, 10] == OnlyEvery.run(2..10, 5, 2)
  end

  test "success: odds" do
    assert [1, 3, 5] == OnlyEvery.run(1..10, 3, 2)
  end
end
