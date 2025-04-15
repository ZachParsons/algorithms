defmodule ShortestCommonSupersequenceTest do
  use ExUnit.Case

  setup do
    %{
      s1: "Jealous",
      s2: "Jewel",
      s3: "Park",
      s4: "Polka"
    }
  end

  test "finds shortest common supersequence for example cases", %{s1: s1, s2: s2, s3: s3, s4: s4} do
    assert ShortestCommonSupersequence.run(s1, s2) in ["Jeawelous", "Jewealous", "Jewaelous"]
    assert ShortestCommonSupersequence.run(s3, s4) in ["Parolka", "Polarka", "Poalrka"]
  end

  test "DP version", %{s1: s1, s2: s2, s3: s3, s4: s4} do
    assert ShortestCommonSupersequence.shortest_common_supersequence(s1, s2) in [
             "Jeawelous",
             "Jewealous",
             "Jewaelous"
           ]
  end
end
