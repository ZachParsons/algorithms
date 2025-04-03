defmodule ShortestCommonSupersequenceTest do
  use ExUnit.Case

  test "finds shortest common supersequence for example cases" do
    s1 = "Jealous"
    s2 = "Jewel"
    s3 = "Park"
    s4 = "Polka"

    assert ShortestCommonSupersequence.run(s1, s2) in ["Jeawelous", "Jewealous", "Jewaelous"]
    assert ShortestCommonSupersequence.run(s3, s4) in ["Parolka", "Polarka", "Poalrka"]
  end
end
