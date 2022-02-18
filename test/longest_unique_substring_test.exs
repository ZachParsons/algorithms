defmodule Algorithms.LongestUniqueSubstringTest do
  use ExUnit.Case
  alias Algorithms.LongestUniqueSubstring, as: LUS

  test "success" do
    assert 3 == LUS.run("abcabcbb")
    assert 1 == LUS.run("bbbbb")
    assert 3 == LUS.run("pwwkew")
  end
end
