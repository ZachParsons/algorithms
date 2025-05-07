defmodule ShortestCommonSupersequenceTest do
  use ExUnit.Case

  @moduledoc """
  This is the code challenge prompt:
  ```
  Given two strings A and B, find the smallest string C that contains both A and B. The characters of A and B have to appear in order, but not contiguously, within C.


  A: Jealous
  B: Jewel
  C: Jeawelous, Jewealous, Jewaelous (any of)

  A: Park
  B: Polka
  C: Parolka, Polarka, Poalrka... (any of)
  """

  setup do
    %{
      case1: [["Jealous", "Jewel"], ["Jeawelous", "Jewealous", "Jewaelous"]],
      case2: [["Park", "Polka"], ["Parolka", "Polarka", "Poalrka"]],
      case3: [["bbbaaaba", "bbababbb"], ["bbbaaababbb"]]
    }
  end

  test "finds shortest common supersequence for example cases", %{
    case1: [[i1, i2], output1],
    case2: [[i3, i4], output2],
    case3: [[i5, i6], output3]
  } do
    assert ShortestCommonSupersequence.Naive.run(i1, i2) in output1
    assert ShortestCommonSupersequence.Naive.run(i3, i4) in output2
    assert ShortestCommonSupersequence.DP.run(i1, i2) in output1
    assert ShortestCommonSupersequence.DP.run(i3, i4) in output2
    assert ShortestCommonSupersequence.DP.run(i5, i6) in output3
  end
end
