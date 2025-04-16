defmodule ShortestCommonSupersequence do
  @moduledoc """
  This is the code challenge prompt:
  ```
  Given two strings A and B, find the smallest string C that contains both A and B. The characters of A and B have to appear in order, but not contiguously, within C.


  A: Jealous
  B: Jewel
  C: Jeawelous, Jewealous, Jewaelous (any of)

  A: Park
  B: Polka
  C: Parolka, Polarka, Poalrka... (any of)
  """

  defmodule Naive do
    @moduledoc false
    def run(s1, s2) do
      chars1 = String.graphemes(s1)
      chars2 = String.graphemes(s2)

      compare([], chars1, chars2)
      |> Enum.reverse()
      |> Enum.join()
    end

    # When all lists are empty - base case.
    def compare([], [], []), do: []

    # When acc empty & both lists start with same char.
    def compare([], [a | t2], [a | t3]), do: compare([a], t2, t3)
    # When acc empty & lists start with different chars.
    def compare([], [h2 | t2], [h3 | t3]), do: compare([h2, h3], t2, t3)

    # When both inputs are emptied.
    def compare(acc, [], []), do: acc

    # When one or the other input is empty.
    def compare(acc, [], [h3 | t3]), do: compare([h3 | acc], [], t3)
    def compare(acc = [a | _t1], [], [a | t3]), do: compare(acc, [], t3)

    # When third list empty & both acc & second list start with same char.
    def compare(acc = [a | _t1], [a | t2], []), do: compare(acc, t2, [])
    # When third list empty & second list non-empty.
    def compare(acc, [h2 | t2], []), do: compare([h2 | acc], t2, [])

    # When all lists non-empty & second & third lists start with same char.
    def compare(acc, [a | t2], [a | t3]), do: compare([a | acc], t2, t3)

    # When all lists start with same char.
    def compare(acc = [a | _t1], [a | t2], [a | t3]), do: compare(acc, t2, t3)
    # When acc & second list start with same char.
    def compare(acc = [a | _t1], [a | t2], chars2), do: compare(acc, t2, chars2)
    # When acc & third list start with same char.
    def compare(acc = [a | _t1], chars1, [a | t3]), do: compare(acc, chars1, t3)

    # When no other patterns match - most general case.
    def compare(acc, [h2 | t2], [h3 | t3]), do: compare([h2, h3 | acc], t2, t3)
  end

  #######################
  defmodule DP do
    @moduledoc false
    @spec run(str1 :: String.t(), str2 :: String.t()) :: String.t()
    def run(str1, str2) do
      bfs(
        :queue.from_list([{0, 0, []}]),
        MapSet.new(),
        str1,
        str2
      )
    end

    defp bfs(queue, seen, str1, str2) do
      {{:value, {i, j, acc}}, queue} = :queue.out(queue)

      if MapSet.member?(seen, {i, j}) do
        bfs(queue, seen, str1, str2)
      else
        seen = MapSet.put(seen, {i, j})

        cond do
          i == byte_size(str1) and j == byte_size(str2) ->
            acc
            |> Enum.reverse()
            |> List.to_string()

          i == byte_size(str1) ->
            queue = :queue.in({i, j + 1, [String.at(str2, j) | acc]}, queue)
            bfs(queue, seen, str1, str2)

          j == byte_size(str2) ->
            queue = :queue.in({i + 1, j, [String.at(str1, i) | acc]}, queue)
            bfs(queue, seen, str1, str2)

          String.at(str1, i) == String.at(str2, j) ->
            queue = :queue.in({i + 1, j + 1, [String.at(str1, i) | acc]}, queue)
            bfs(queue, seen, str1, str2)

          true ->
            queue = :queue.in({i + 1, j, [String.at(str1, i) | acc]}, queue)
            queue = :queue.in({i, j + 1, [String.at(str2, j) | acc]}, queue)
            bfs(queue, seen, str1, str2)
        end
      end
    end
  end
end
