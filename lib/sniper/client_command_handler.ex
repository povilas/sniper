defmodule Sniper.ClientCommandHandler do

  alias Sniper.ClientCommand
  alias Sniper.AuctionCommand

  def handle(%ClientCommand.Start{id: id, item: item, price: price}, state) do
    {:ok,
     [auction: %AuctionCommand.Join{id: id}],
     %{state | id: id, item: item, stop_price: price}}
  end

end
