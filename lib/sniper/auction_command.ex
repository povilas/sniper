defmodule Sniper.AuctionCommand do

  defmodule Bid, do: defstruct [:price]
  defmodule Join, do: defstruct [:id]

  def encode(%Bid{} = s), do: "BID #{s.price}\r\n"
  def encode(%Join{} = s), do: "JOIN #{s.id}\r\n"

end
