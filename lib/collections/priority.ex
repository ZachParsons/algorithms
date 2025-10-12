defmodule Algorithms.Collections.Priority do
  @moduledoc """
  A simple priority queue implementation using a list of {priority, item} tuples.
  Items with lower priority values are dequeued first.
  """

  defstruct items: []

  @type t :: %__MODULE__{items: [{number(), any()}]}

  def new, do: %__MODULE__{}

  def empty?(%__MODULE__{items: []}), do: true
  def empty?(%__MODULE__{}), do: false

  def enqueue(%__MODULE__{items: items}, item, priority) do
    # Only add if item is not already in queue
    if Enum.any?(items, fn {_, existing_item} -> existing_item == item end) do
      %__MODULE__{items: items}
    else
      new_items = [{priority, item} | items] |> Enum.sort_by(&elem(&1, 0))
      %__MODULE__{items: new_items}
    end
  end

  def dequeue(%__MODULE__{items: []}), do: {nil, %__MODULE__{}}

  def dequeue(%__MODULE__{items: [{_priority, item} | rest]}) do
    {item, %__MODULE__{items: rest}}
  end

  def member?(%__MODULE__{items: items}, item) do
    Enum.any?(items, fn {_, existing_item} -> existing_item == item end)
  end
end
