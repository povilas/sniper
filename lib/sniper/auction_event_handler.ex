defmodule Sniper.AuctionEventHandler do

  alias Sniper.AuctionEvent
  alias Sniper.AuctionCommand
  alias Sniper.ClientEvent

  def handle(%AuctionEvent.Closed{}, %{winning: false} = state) do
    {:ok, [client: %ClientEvent.Lost{}], state}
  end

  def handle(%AuctionEvent.Closed{}, %{winning: true} = state) do
    {:ok, [client: %ClientEvent.Won{}], state}
  end

  def handle(%AuctionEvent.Price{bidder: id}, %{id: id} = state) do
    {:ok,
     [client: %ClientEvent.Winning{}],
     %{state | winning: true}}
  end

  def handle(%AuctionEvent.Price{} = event, state) do
    {:ok,
     [client: %ClientEvent.Bidding{},
      auction: %AuctionCommand.Bid{price: event.price + event.increment}],
     state}
  end

end
