defmodule Algorithms.Sets.SetCoverTest do
  use ExUnit.Case
  alias Algorithms.Sets.SetCover

  test "1" do
    req_skills = ["java", "nodejs", "reactjs"]
    people = [["java"], ["nodejs"], ["nodejs", "reactjs"]]
    expected = [0, 2]

    res = SetCover.run(req_skills, people)
    assert expected == res
  end

  test "2" do
    req_skills = ["algorithms", "math", "java", "reactjs", "csharp", "aws"]

    people = [
      ["algorithms", "math", "java"],
      ["algorithms", "math", "reactjs"],
      ["java", "csharp", "aws"],
      ["reactjs", "csharp"],
      ["csharp", "math"],
      ["aws", "java"]
    ]

    expected = [1, 2]
    res = SetCover.run(req_skills, people)
    assert expected == res
  end

  test "3" do
    req_skills =
      ["ohmvnkxnokpnwxmr", "jdjdb", "azdwg", "xvn", "mljb", "rdaavykiextpr", "ztp"]

    people =
      [
        ["azdwg"],
        ["ohmvnkxnokpnwxmr", "mljb"],
        ["jdjdb"],
        [],
        [],
        [],
        ["xvn", "mljb"],
        [],
        ["xvn"],
        [],
        ["xvn"],
        ["jdjdb", "mljb"],
        [],
        ["ohmvnkxnokpnwxmr", "mljb", "ztp"],
        ["ohmvnkxnokpnwxmr"],
        [],
        [],
        ["ohmvnkxnokpnwxmr", "jdjdb"],
        ["jdjdb"],
        [],
        [],
        [],
        ["azdwg", "mljb"],
        ["ztp"],
        ["xvn"],
        ["jdjdb"],
        ["mljb"],
        ["xvn"],
        ["rdaavykiextpr"],
        [],
        [],
        ["ohmvnkxnokpnwxmr", "jdjdb", "mljb", "rdaavykiextpr"],
        [],
        ["jdjdb", "mljb", "rdaavykiextpr", "ztp"],
        ["ohmvnkxnokpnwxmr"],
        ["rdaavykiextpr", "ztp"],
        ["mljb"],
        ["rdaavykiextpr"],
        [],
        ["azdwg"],
        [],
        ["rdaavykiextpr"],
        ["jdjdb"],
        [],
        ["mljb", "ztp"],
        [],
        ["rdaavykiextpr", "ztp"],
        ["jdjdb", "azdwg"],
        ["xvn", "ztp"],
        []
      ]

    expected = [31, 47, 48]
    res = SetCover.run(req_skills, people)
    assert expected == res
  end
end
