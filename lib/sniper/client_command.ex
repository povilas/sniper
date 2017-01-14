defmodule Sniper.AuctionEvent do

  defmodule Closed, do: defstruct []
  defmodule Price, do: defstruct [:price, :increment]

  def decode("CLOSE" <> _) do
    %Closed{}
  end

  def decode("PRICE" <> msg) do
    [price, increment, _] = msg |> String.trim |> String.split(",")
    %Price{price: String.to_integer(price), increment: String.to_integer(increment)}
  end
  
end
