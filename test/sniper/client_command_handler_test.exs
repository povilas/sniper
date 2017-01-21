defmodule Sniper.ClientCommandHandlerTest do

  use ExUnit.Case
  import Sniper.ClientCommandHandler, only: [handle: 2]
  alias Sniper.ClientCommand
  alias Sniper.AuctionCommand

  test "handle start as join" do
    state =  %{id: nil, item: nil, stop_price: nil}
    assert handle(%ClientCommand.Start{id: "id", item: "item", price: 42}, state) ==
      {:ok,
       [auction: %AuctionCommand.Join{id: "id"}],
       %{id: "id", item: "item", stop_price: 42}}
  end

end
