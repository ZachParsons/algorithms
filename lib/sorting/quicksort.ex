defmodule Algorithms.Sorting.Quicksort do
  @moduledoc """
  Quicksort is a divide-and-conquer algorithm that works by selecting a 'pivot' element
  from the array and partitioning the other elements into two sub-arrays according to
  whether they are less than or greater than the pivot.
  """

  @doc """
  Sequential quicksort implementation using first element as pivot.
  """
  def sort([]), do: []

  def sort([h | t]) do
    {lesser, greater} = Enum.split_with(t, &(&1 < h))
    sort(lesser) ++ [h] ++ sort(greater)
  end

  @doc """
  Parallel quicksort implementation that spawns processes for concurrent sorting.

  Uses logarithmic depth based on number of schedulers to balance parallelism
  with overhead. When depth reaches 0, falls back to sequential sorting.

  """
  def parallel_sort(list) do
    schedulers = System.schedulers()
    depth = trunc(:math.log2(schedulers))
    qs(list, depth)
  end

  # Base case: empty list
  defp qs([], _depth), do: []

  # Parallel case: spawn processes when depth > 0
  defp qs([h | t], depth) when depth > 0 do
    parent = self()
    ref = make_ref()

    # Spawn process to sort elements less than pivot
    spawn(fn ->
      lesser = for e <- t, e < h, do: e
      result = qs(lesser, depth - 1)
      send(parent, {:l1, ref, result})
    end)

    # Spawn process to sort elements greater than or equal to pivot
    spawn(fn ->
      greater = for e <- t, h <= e, do: e
      result = qs(greater, depth - 1)
      send(parent, {:l2, ref, result})
    end)

    # Collect results from both processes
    {l1, l2} = receive_results(ref, nil, nil)
    l1 ++ [h] ++ l2
  end

  # Sequential case: when depth is 0 or negative, use sequential sorting
  defp qs([h | t], _depth) do
    lesser = for e <- t, e < h, do: e
    greater = for e <- t, h <= e, do: e
    qs(lesser, 0) ++ [h] ++ qs(greater, 0)
  end

  # Receives results from spawned processes
  defp receive_results(ref, l1, l2) do
    receive do
      {:l1, ^ref, l1_result} when l2 == nil ->
        receive_results(ref, l1_result, l2)

      {:l2, ^ref, l2_result} when l1 == nil ->
        receive_results(ref, l1, l2_result)

      {:l1, ^ref, l1_result} ->
        {l1_result, l2}

      {:l2, ^ref, l2_result} ->
        {l1, l2_result}
    after
      5000 ->
        receive_results(ref, l1, l2)
    end
  end
end
