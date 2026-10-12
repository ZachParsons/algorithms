defmodule Algorithms.Sets.SubsetEqualSum do
  def run(input) do
    total = Enum.sum(input)
    target = total / 2
    trunced_target = trunc(target)

    if target == trunced_target do
      base_row = MapSet.new([0])

      final_row =
        Enum.reduce(input, base_row, fn value, row ->
          0..trunced_target
          |> Enum.filter(fn col_idx ->
            MapSet.member?(row, col_idx) ||
              (col_idx >= value && MapSet.member?(row, col_idx - value))
          end)
          |> MapSet.new()
        end)

      MapSet.member?(final_row, trunced_target)
    else
      false
    end
  end
end
