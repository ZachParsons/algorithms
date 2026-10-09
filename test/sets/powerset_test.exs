defmodule Algorithms.Set.PowersetTest do
  use ExUnit.Case
  alias Algorithms.Sets.Powerset

  test "success" do
    assert [
             [],
             [3],
             [2],
             [2, 3],
             [1],
             [1, 3],
             [1, 2],
             [1, 2, 3]
           ] ==
             Powerset.run([1, 2, 3])
  end
end
