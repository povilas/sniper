defmodule Sniper.ClientCommandHandler do

  alias Sniper.ClientCommand
  alias Sniper.AuctionCommand

  def handle(%ClientCommand.Start{}) do
    [auction: %AuctionCommand.Join{id: "sniper"}]
  end

end
