defmodule Sniper.AuctionEventTest do

  use ExUnit.Case
  import Sniper.AuctionEvent, only: [decode: 1]
  alias Sniper.AuctionEvent.Closed
  alias Sniper.AuctionEvent.Price

  test "decode close" do
    assert decode("CLOSE\r\n") == %Closed{}
  end

  test "decode price" do
    assert decode("PRICE 123,5,Mike\r\n") == %Price{price: 123, increment: 5}
  end

end
