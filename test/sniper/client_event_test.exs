defmodule Sniper.ClientEventTest do

  use ExUnit.Case
  import Sniper.ClientEvent, only: [encode: 1]
  alias Sniper.ClientEvent.Lost
  alias Sniper.ClientEvent.Won
  alias Sniper.ClientEvent.Bidding
  alias Sniper.ClientEvent.Winning
  alias Sniper.ClientEvent.Losing

  test "encode lost" do
    assert encode(%Lost{}) == "LOST\r\n"
  end

  test "encode won" do
    assert encode(%Won{}) == "WON\r\n"
  end

  test "encode bidding" do
    assert encode(%Bidding{}) == "I'M BIDDING\r\n"
  end

  test "encode winning" do
    assert encode(%Winning{}) == "I'M WINNING\r\n"
  end

  test "encode losing" do
    assert encode(%Losing{last_price: 43, last_bid: 21}) == "I'M LOSING 43,21\r\n"
  end
end
