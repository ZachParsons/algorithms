defmodule Algorithms.Collections.SlidingWindowMaxTest do
  use ExUnit.Case
  alias Algorithms.Collections.SlidingWindowMax

  test "sliding window maximum with mixed positive and negative numbers" do
    nums = [1, 3, -1, -3, 5, 3, 6, 7]
    window_size = 3
    output = [3, 3, 5, 5, 6, 7]
    res0 = SlidingWindowMax.run0(nums, window_size)
    res1 = SlidingWindowMax.run1(nums, window_size)
    assert output == res0
    assert output == res1
  end

  test "sliding window maximum with single element" do
    nums = [1]
    window_size = 1
    output = [1]
    res0 = SlidingWindowMax.run0(nums, window_size)
    res1 = SlidingWindowMax.run1(nums, window_size)
    assert output == res0
    assert output == res1
  end
end
