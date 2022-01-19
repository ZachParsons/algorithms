defmodule Algorithms.FactorialTest do
  use ExUnit.Case
  alias Algorithms.Factorial

  describe "Enumeration reduce" do
    test "0..19" do
      result =
        0..19
        |> Enum.map(&Factorial.run/1)

      assert result == [
               1,
               1,
               2,
               6,
               24,
               120,
               720,
               5040,
               40320,
               362_880,
               3_628_800,
               39_916_800,
               479_001_600,
               6_227_020_800,
               87_178_291_200,
               1_307_674_368_000,
               20_922_789_888_000,
               355_687_428_096_000,
               6_402_373_705_728_000,
               121_645_100_408_832_000
             ]
    end

    test "invalid" do
      result =
        [
          "a",
          :a,
          1.5
        ]
        |> Enum.map(&Factorial.run/1)

      assert Enum.all?(
               result,
               &(&1 == "invalid input")
             )
    end
  end

  describe "tail recursive" do
    test "0..19" do
      result =
        0..19
        |> Enum.map(&Factorial.run_tr/1)

      assert result == [
               1,
               1,
               2,
               6,
               24,
               120,
               720,
               5040,
               40320,
               362_880,
               3_628_800,
               39_916_800,
               479_001_600,
               6_227_020_800,
               87_178_291_200,
               1_307_674_368_000,
               20_922_789_888_000,
               355_687_428_096_000,
               6_402_373_705_728_000,
               121_645_100_408_832_000
             ]
    end

    test "invalid" do
      result =
        [
          "a",
          :a,
          1.5
        ]
        |> Enum.map(&Factorial.run_tr/1)

      assert Enum.all?(
               result,
               &(&1 == "invalid input")
             )
    end
  end
end
