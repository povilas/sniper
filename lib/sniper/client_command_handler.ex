defmodule Sniper.ClientCommandHandler do

  alias Sniper.ClientCommand
  alias Sniper.AuctionCommand

  def handle(%ClientCommand.Start{}, state) do
    {:ok,
     [auction: %AuctionCommand.Join{id: state.id}],
     state}
  end

end
