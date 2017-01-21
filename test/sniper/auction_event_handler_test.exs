defmodule Sniper.AuctionEventHandlerTest do

  use ExUnit.Case
  import Sniper.AuctionEventHandler, only: [handle: 2]
  alias Sniper.AuctionEvent
  alias Sniper.AuctionCommand
  alias Sniper.ClientEvent

  test "handle closed as lost" do
    assert handle(%AuctionEvent.Closed{}, %{winning: false}) ==
      {:ok, [client: %ClientEvent.Lost{}], %{winning: false}}
  end

  test "handle closed as won" do
    assert handle(%AuctionEvent.Closed{}, %{winning: true}) ==
      {:ok, [client: %ClientEvent.Won{}], %{winning: true}}
  end

  test "handle price update as bid if price was by other bidder" do
    state = %{id: "sniper", stop_price: :undefined, last_bid: nil}
    assert handle(%AuctionEvent.Price{price: 123, increment: 5, bidder: "other"}, state) ==
      {:ok,
       [client: %ClientEvent.Bidding{}, auction: %AuctionCommand.Bid{price: 128}],
       %{id: "sniper", stop_price: :undefined, last_bid: 128}}
  end

  test "handle price update as winning if bid was by sniper" do
    state = %{id: "sniper", winning: false}
    assert handle(%AuctionEvent.Price{price: 123, increment: 5, bidder: "sniper"}, state) ==
      {:ok,
       [client: %ClientEvent.Winning{}],
       %{id: "sniper", winning: true}}
  end

  test "handle price update as losing if bid would be higher ten stop price" do
    state = %{id: "sniper", stop_price: 127, last_bid: 99, winning: true}
    assert handle(%AuctionEvent.Price{price: 123, increment: 5, bidder: "other"}, state) ==
      {:ok,
       [client: %ClientEvent.Losing{last_price: 123, last_bid: 99}],
       state}
  end

end
