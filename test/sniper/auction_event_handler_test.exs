defmodule Sniper.AuctionEventHandlerTest do

  use ExUnit.Case
  import Sniper.AuctionEventHandler, only: [handle: 1]
  alias Sniper.AuctionEvent
  alias Sniper.AuctionCommand
  alias Sniper.ClientEvent

  test "handle closed as lost" do
    assert handle(%AuctionEvent.Closed{}) ==
      [client: %ClientEvent.Lost{}]
  end

  test "handle price update as bid" do
    assert handle(%AuctionEvent.Price{price: 123, increment: 5}) ==
      [client: %ClientEvent.Bidding{},
       auction: %AuctionCommand.Bid{price: 128}]
  end

end
