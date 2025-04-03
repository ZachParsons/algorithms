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

  def run(s1, s2) do
    chars1 = String.graphemes(s1)
    chars2 = String.graphemes(s2)

    compare([], chars1, chars2)
    |> Enum.reverse()
    |> Enum.join()
  end

  def compare([], [], []), do: []

  def compare([], [a | t2], [a | t3]), do: compare([a], t2, t3)
  def compare([], [h2 | t2], [h3 | t3]), do: compare([h2, h3], t2, t3)
  def compare(acc, [], []), do: acc

  def compare(acc, [], [h3 | t3]), do: compare([h3 | acc], [], t3)
  def compare(acc = [a | _t1], [], [a | t3]), do: compare(acc, [], t3)

  def compare(acc = [a | _t1], [a | t2], []), do: compare(acc, t2, [])
  def compare(acc, [h2 | t2], []), do: compare([h2 | acc], t2, [])

  # Non-empties.
  def compare(acc, [a | t2], [a | t3]), do: compare([a | acc], t2, t3)

  def compare(acc = [a | _t1], [a | t2], [a | t3]), do: compare(acc, t2, t3)
  def compare(acc = [a | _t1], [a | t2], chars2), do: compare(acc, t2, chars2)
  def compare(acc = [a | _t1], chars1, [a | t3]), do: compare(acc, chars1, t3)

  # Most unique case.
  def compare(acc, [h2 | t2], [h3 | t3]), do: compare([h2, h3 | acc], t2, t3)
end
