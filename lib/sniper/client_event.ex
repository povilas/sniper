defmodule Sniper.ClientEvent do

  defmodule Lost, do: defstruct []
  defmodule Won, do: defstruct []
  defmodule Bidding, do: defstruct []
  defmodule Winning, do: defstruct []
  defmodule Losing, do: defstruct [:last_price, :last_bid]

  def encode(%Lost{}), do: "LOST\r\n"
  def encode(%Won{}), do: "WON\r\n"
  def encode(%Bidding{}), do: "I'M BIDDING\r\n"
  def encode(%Winning{}), do: "I'M WINNING\r\n"
  def encode(%Losing{last_price: price, last_bid: bid}), do: "I'M LOSING #{price},#{bid}\r\n"

end
