defmodule Algorithms.FactorialBenchmarks do
  @moduledoc """
    To run: `mix run <path>`.
  """
  alias Algorithms.Factorial

  Benchee.run(
    %{
      "factorial" => fn ->
        Factorial.run(5)
      end
    }
  )
end
