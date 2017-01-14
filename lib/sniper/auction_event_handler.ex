defmodule Sniper.AuctionEventHandler do

  alias Sniper.AuctionEvent
  alias Sniper.AuctionCommand
  alias Sniper.ClientEvent

  def handle(%AuctionEvent.Closed{}) do
    [client: %ClientEvent.Lost{}]
  end

  def handle(%AuctionEvent.Price{} = event) do
    [client: %ClientEvent.Bidding{},
     auction: %AuctionCommand.Bid{price: event.price + event.increment}]
  end

end
