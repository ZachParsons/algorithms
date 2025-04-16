# Trade:
# id, type (BUY/SELL), totalGold, totalUSD
# where:
# totalGold, totalUSD > 0

# Net Position:
# netGold, netUSD
# where:
# -Infinity < netGold, netUSD < Infinity

# Problem 1:
# Input: List of `Trade`s
# Output: Net Position for those trades

# Example:
# For the two trades with ids "A" and "B" here
#  * “A”, BUY, totalGold = 1, totalUSD = 1750
#  * “B”, SELL, totalGold = 0.25, totalUSD = 750

# The Net Position is:
#     netGold = 0.75, netUSD = -1000

# pseudocode
# define a DS for a Trade
#   id, type, totalGold, totalUSD
#   constructor to enforce the where condition

# function for calculation on a list of Trades
#   reduce, return DS with netGold & netUSD

# TODO store monetary values as integers * 10
defmodule NetPosition do
  @moduledoc false
  defstruct net_gold: nil,
            net_USD: nil

  @type t() :: %__MODULE__{
          net_gold: float(),
          net_USD: float()
        }

  defmodule Trade do
    @moduledoc false

    defstruct id: nil,
              type: nil,
              total_gold: nil,
              total_USD: nil

    @type t() :: %__MODULE__{
            id: binary(),
            type: atom(),
            total_gold: float(),
            total_USD: float()
          }
  end

  @spec calculate_daily(list(Trade)) :: NetPosition
  def calculate_daily(trades_list) do
    trades_list
    |> Enum.reduce(
      %NetPosition{net_gold: nil, net_USD: nil},
      fn trade, accumulator ->
        trade.type
        |> case do
          :BUY ->
            %NetPosition{
              net_gold: accumulator.net_gold + trade.total_gold,
              net_USD: accumulator.net_USD - trade.total_USD
            }

          :SELL ->
            %NetPosition{
              net_gold: accumulator.net_gold - trade.total_gold,
              net_USD: accumulator.net_USD + trade.total_USD
            }
        end
      end
    )
  end

  # Trade:
  # id, type (BUY/SELL), totalGold, totalUSD, ourTag, theirTag
  # where:
  # totalGold, totalUSD > 0
  # for all ourTag theirTag, ourTag != theirTag (these are non-intersecting sets)

  # Trades:
  # * E: ourTag = “q”, theirTag = “6”
  # * A: ourTag = “x”, theirTag = “0”
  # * B: ourTag = “x”, theirTag = “1”
  # * C: ourTag = “q”, theirTag = “1”
  # * D: ourTag = “z”, theirTag = “2”

  # A,B,C, E are in the same group.
  # D is in a group by itself.

  # Problem 2:
  # Input: List of Trades, a tag
  # Output: The NetPosition for the group of Trades containing that tag.

  # pseudocode
  # DONT DO
  # filtered_trades = enumerate trades_list, return all trades which has given
  # collect all others in filtered_trades
  # filtered_other_tags = enumerate through trades_list, return all trades within filtered_trades' others tags
  # merge & dedup

  # @spec net_with_tag(list(Trade), atom()) :: NetPosition
  # def net_with_tag(trades_list, tag) do
  #   trades_list
  #   |> Enum.filter(fn(trade)->

  #   end)
  # end

  # TODO refarctor approach:
  #   1. make a map of the tags,
  #   2. enum through trades_list to get all matching trades
end
