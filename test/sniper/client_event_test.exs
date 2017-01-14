defmodule Sniper.ClientEventTest do

  use ExUnit.Case
  import Sniper.ClientEvent, only: [encode: 1]
  alias Sniper.ClientEvent.Lost
  alias Sniper.ClientEvent.Bidding

  test "encode list" do
    assert encode(%Lost{}) == "LOST\r\n"
  end

  test "encode bidding" do
    assert encode(%Bidding{}) == "I'M BIDDING\r\n"
  end
end
