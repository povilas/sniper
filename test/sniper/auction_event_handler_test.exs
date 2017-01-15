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
    state = %{id: "sniper"}
    assert handle(%AuctionEvent.Price{price: 123, increment: 5, bidder: "other"}, state) ==
      {:ok,
       [client: %ClientEvent.Bidding{}, auction: %AuctionCommand.Bid{price: 128}],
       state}
  end

  test "handle price update as winning if bid was by sniper" do
    state = %{id: "sniper", winning: false}
    assert handle(%AuctionEvent.Price{price: 123, increment: 5, bidder: "sniper"}, state) ==
      {:ok,
       [client: %ClientEvent.Winning{}],
       %{id: "sniper", winning: true}}
  end

end
