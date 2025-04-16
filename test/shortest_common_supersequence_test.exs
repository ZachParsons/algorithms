defmodule ShortestCommonSupersequenceTest do
  use ExUnit.Case

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
    assert ShortestCommonSupersequence.Solution.shortest_common_supersequence(i1, i2) in output1
    assert ShortestCommonSupersequence.Solution.shortest_common_supersequence(i3, i4) in output2
    assert ShortestCommonSupersequence.Solution.shortest_common_supersequence(i5, i6) in output3
  end
end
