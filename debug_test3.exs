alias Algorithms.Sets.SetCover

req_skills = ["ohmvnkxnokpnwxmr", "jdjdb", "azdwg", "xvn", "mljb", "rdaavykiextpr", "ztp"]

people = [
  ["azdwg"],                                                    # 0
  ["ohmvnkxnokpnwxmr", "mljb"],                               # 1
  ["jdjdb"],                                                   # 2
  [],                                                          # 3
  [],                                                          # 4
  [],                                                          # 5
  ["xvn", "mljb"],                                            # 6
  [],                                                          # 7
  ["xvn"],                                                     # 8
  [],                                                          # 9
  ["xvn"],                                                     # 10
  ["jdjdb", "mljb"],                                          # 11
  [],                                                          # 12
  ["ohmvnkxnokpnwxmr", "mljb", "ztp"],                       # 13
  ["ohmvnkxnokpnwxmr"],                                       # 14
  [],                                                          # 15
  [],                                                          # 16
  ["ohmvnkxnokpnwxmr", "jdjdb"],                             # 17
  ["jdjdb"],                                                   # 18
  [],                                                          # 19
  [],                                                          # 20
  [],                                                          # 21
  ["azdwg", "mljb"],                                          # 22
  ["ztp"],                                                     # 23
  ["xvn"],                                                     # 24
  ["jdjdb"],                                                   # 25
  ["mljb"],                                                    # 26
  ["xvn"],                                                     # 27
  ["rdaavykiextpr"],                                          # 28
  [],                                                          # 29
  [],                                                          # 30
  ["ohmvnkxnokpnwxmr", "jdjdb", "mljb", "rdaavykiextpr"],   # 31 *** EXPECTED
  [],                                                          # 32
  ["jdjdb", "mljb", "rdaavykiextpr", "ztp"],                 # 33
  ["ohmvnkxnokpnwxmr"],                                       # 34
  ["rdaavykiextpr", "ztp"],                                   # 35
  ["mljb"],                                                    # 36
  ["rdaavykiextpr"],                                          # 37
  [],                                                          # 38
  ["azdwg"],                                                   # 39
  [],                                                          # 40
  ["rdaavykiextpr"],                                          # 41
  ["jdjdb"],                                                   # 42
  [],                                                          # 43
  ["mljb", "ztp"],                                            # 44
  [],                                                          # 45
  ["rdaavykiextpr", "ztp"],                                   # 46
  ["jdjdb", "azdwg"],                                         # 47 *** EXPECTED
  ["xvn", "ztp"],                                             # 48 *** EXPECTED
  []                                                           # 49
]

IO.puts("\n=== Test 3 ===")
IO.puts("Required skills: #{inspect(req_skills)}")
IO.puts("\nExpected solution:")
IO.puts("Person 31: #{inspect(Enum.at(people, 31))}")
IO.puts("Person 47: #{inspect(Enum.at(people, 47))}")
IO.puts("Person 48: #{inspect(Enum.at(people, 48))}")

expected_coverage = MapSet.union(
  MapSet.union(MapSet.new(Enum.at(people, 31)), MapSet.new(Enum.at(people, 47))),
  MapSet.new(Enum.at(people, 48))
)
IO.puts("Expected coverage: #{inspect(expected_coverage)}")
IO.puts("All skills covered? #{MapSet.equal?(MapSet.new(req_skills), expected_coverage)}")

IO.puts("\n--- Running algorithm ---")
result = SetCover.run(req_skills, people)
IO.puts("\nAlgorithm result: #{inspect(result)}")
IO.puts("Expected result: [31, 47, 48]")

IO.puts("\nAlgorithm solution:")
Enum.each(result, fn idx ->
  IO.puts("Person #{idx}: #{inspect(Enum.at(people, idx))}")
end)

