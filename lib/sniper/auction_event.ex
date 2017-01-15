defmodule Sniper.AuctionEvent do

  defmodule Closed, do: defstruct []
  defmodule Price, do: defstruct [:price, :increment, :bidder]

  def decode("CLOSE" <> _) do
    %Closed{}
  end

  def decode("PRICE" <> msg) do
    [price, increment, bidder] = msg |> String.trim |> String.split(",")
    %Price{price: String.to_integer(price), increment: String.to_integer(increment), bidder: bidder}
  end

end
