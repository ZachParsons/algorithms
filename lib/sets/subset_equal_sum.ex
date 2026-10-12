defmodule Algorithms.Sets.SubsetEqualSum do
  def run(input) do
    total = Enum.sum(input)
    target = total / 2
    trunced_target = trunc(target)

    if target == trunced_target do
      table =
        MapSet.new([{0, 0}])

      input_length = length(input)

      res =
        Enum.reduce(1..input_length, table, fn row_idx, row_acc ->
          input_el = Enum.at(input, row_idx - 1)

          new_cells =
            0..trunced_target
            |> Enum.filter(fn col_idx ->
              MapSet.member?(row_acc, {row_idx - 1, col_idx}) ||
                (col_idx >= input_el &&
                   MapSet.member?(row_acc, {row_idx - 1, col_idx - input_el}))
            end)
            |> Enum.map(&{row_idx, &1})
            |> MapSet.new()

          MapSet.union(row_acc, new_cells)
        end)

      MapSet.member?(res, {input_length, trunced_target})
    else
      false
    end
  end
end
