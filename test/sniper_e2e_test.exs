defmodule SniperE2ETest do
  use ExUnit.Case

  setup do
    {:ok, _} = FakeAuctionServer.start_link()
    {:ok, _} = SniperRunner.start_link()
    {:ok, auction: FakeAuctionServer, sniper: SniperRunner}
  end

  test "sniper joins auction until auction closes", %{auction: auction, sniper: sniper} do
    auction.start_selling_item()
    sniper.start_bidding()
    assert auction.has_received_join_request_from_sniper()
    auction.announce_closed()
    assert sniper.shows_sniper_has_lost_auction()
  end

end
