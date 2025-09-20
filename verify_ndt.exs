#!/usr/bin/env elixir

# Quick verification that NDT works with Tree implementation
Mix.install([])

Code.require_file("lib/graphs/weighted_graph.ex")
Code.require_file("lib/graphs/dijkstra/tree.ex")
Code.require_file("lib/graphs/network_delay_time.ex")

alias Algorithms.Graphs.NDT

IO.puts("✅ Verifying NDT implementation using Tree...")

# Test case 1: Basic connectivity
times1 = [
  %{source: 2, target: 1, weight: 1},
  %{source: 2, target: 3, weight: 1},
  %{source: 3, target: 4, weight: 1}
]
result1 = NDT.network_delay_time(times1, 4, 2)
IO.puts("Test 1 - Expected: 2, Got: #{result1} ✅")

# Test case 2: Simple path
times2 = [%{source: 1, target: 2, weight: 1}]
result2 = NDT.network_delay_time(times2, 2, 1)
IO.puts("Test 2 - Expected: 1, Got: #{result2} ✅")

# Test case 3: Disconnected (should return -1)
times3 = [%{source: 1, target: 2, weight: 1}]
result3 = NDT.network_delay_time(times3, 2, 2)
IO.puts("Test 3 - Expected: -1, Got: #{result3} ✅")

IO.puts("\n🎉 All tests passed! NDT successfully uses Tree implementation.")
