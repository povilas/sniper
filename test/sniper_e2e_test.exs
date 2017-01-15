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
    assert auction.has_received_join_request_from("sniper")

    auction.announce_closed()
    assert sniper.shows_it_has_lost_auction()
  end

  test "sniper makes a higher bid but loses", %{auction: auction, sniper: sniper} do
    auction.start_selling_item()

    sniper.start_bidding()
    assert auction.has_received_join_request_from("sniper")

    auction.report_price(1000, 98, "other bidder")
    assert sniper.shows_it_is_bidding()
    assert auction.has_received_bid(1098, "sniper")

    auction.announce_closed()
    assert sniper.shows_it_has_lost_auction()
  end

  test "sniper wins an auction by bidding higher", %{auction: auction, sniper: sniper} do
    auction.start_selling_item()

    sniper.start_bidding()
    assert auction.has_received_join_request_from("sniper")

    auction.report_price(1000, 98, "other bidder")
    assert sniper.shows_it_is_bidding()
    assert auction.has_received_bid(1098, "sniper")

    auction.report_price(1098, 97, "sniper")
    assert sniper.shows_it_is_winning()

    auction.announce_closed()
    assert sniper.shows_it_has_won_auction()
  end

end
