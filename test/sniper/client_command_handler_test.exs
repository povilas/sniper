defmodule Sniper.ClientCommandHandlerTest do

  use ExUnit.Case
  import Sniper.ClientCommandHandler, only: [handle: 1]
  alias Sniper.ClientCommand
  alias Sniper.AuctionCommand

  test "handle start as join" do
    assert handle(%ClientCommand.Start{}) ==
      [auction: %AuctionCommand.Join{id: "sniper"}]
  end

end
