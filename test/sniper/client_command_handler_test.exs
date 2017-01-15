defmodule Sniper.ClientCommandHandlerTest do

  use ExUnit.Case
  import Sniper.ClientCommandHandler, only: [handle: 2]
  alias Sniper.ClientCommand
  alias Sniper.AuctionCommand

  test "handle start as join" do
    state =  %{id: "sniper"}
    assert handle(%ClientCommand.Start{}, state) ==
      {:ok, [auction: %AuctionCommand.Join{id: "sniper"}], state}
  end

end
