defmodule Sniper.ClientEventTest do

  use ExUnit.Case
  import Sniper.ClientEvent, only: [encode: 1]
  alias Sniper.ClientEvent.Lost
  alias Sniper.ClientEvent.Won
  alias Sniper.ClientEvent.Bidding
  alias Sniper.ClientEvent.Winning

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
end
