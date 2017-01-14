defmodule Sniper.AuctionCommandTest do

  use ExUnit.Case
  import Sniper.AuctionCommand, only: [encode: 1]
  alias Sniper.AuctionCommand.Bid
  alias Sniper.AuctionCommand.Join

  test "encode bid" do
    assert encode(%Bid{price: 123}) == "BID 123\r\n"
  end

  test "encode join" do
    assert encode(%Join{id: "foo"}) == "JOIN foo\r\n"
  end

end
