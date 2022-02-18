defmodule Algorithms.LongestSubstringTest do
  use ExUnit.Case
  alias Algorithms.LongestSubstring

  test "success" do
    assert 3 == LongestSubstring.run("abcabcbb")
    assert 1 == LongestSubstring.run("bbbbb")
    assert 3 == LongestSubstring.run("pwwkew")
  end
end
