defmodule SniperE2ETest do
  use ExUnit.Case

  setup do
    {:ok, _} = FakeAuctionServer.start_link()
    {:ok, _} = SniperRunner.start_link()
    {:ok, auction: FakeAuctionServer, sniper: SniperRunner}
  end

  test "sniper joins auction until auction closes", %{auction: auction, sniper: sniper} do
    auction.start_selling_item("item-1")

    sniper.start_bidding("item-1")
    assert auction.has_received_join_request_from("item-1", "sniper")

    auction.announce_closed("item-1")
    assert sniper.shows_it_has_lost_auction("item-1")
  end

  test "sniper makes a higher bid but loses", %{auction: auction, sniper: sniper} do
    auction.start_selling_item("item-1")

    sniper.start_bidding("item-1")
    assert auction.has_received_join_request_from("item-1", "sniper")

    auction.report_price("item-1", 1000, 98, "other bidder")
    assert sniper.shows_it_is_bidding("item-1")
    assert auction.has_received_bid("item-1", 1098, "sniper")

    auction.announce_closed("item-1")
    assert sniper.shows_it_has_lost_auction("item-1")
  end

  test "sniper wins an auction by bidding higher", %{auction: auction, sniper: sniper} do
    auction.start_selling_item("item-1")

    sniper.start_bidding("item-1")
    assert auction.has_received_join_request_from("item-1", "sniper")

    auction.report_price("item-1", 1000, 98, "other bidder")
    assert sniper.shows_it_is_bidding("item-1")
    assert auction.has_received_bid("item-1", 1098, "sniper")

    auction.report_price("item-1", 1098, 97, "sniper")
    assert sniper.shows_it_is_winning("item-1")

    auction.announce_closed("item-1")
    assert sniper.shows_it_has_won_auction("item-1")
  end

  test "sniper bids for multiple items", %{auction: auction, sniper: sniper} do
    auction.start_selling_item("item-1")
    sniper.start_bidding("item-1")
    assert auction.has_received_join_request_from("item-1", "sniper")

    auction.start_selling_item("item-2")
    sniper.start_bidding("item-2")
    assert auction.has_received_join_request_from("item-2", "sniper")

    auction.report_price("item-1", 1000, 98, "other bidder")
    assert auction.has_received_bid("item-1", 1098, "sniper")

    auction.report_price("item-2", 500, 21, "other bidder")
    assert auction.has_received_bid("item-2", 521, "sniper")

    auction.report_price("item-1", 1098, 97, "sniper")
    auction.report_price("item-2", 521, 22, "sniper")

    assert sniper.shows_it_is_winning("item-1")
    assert sniper.shows_it_is_winning("item-2")

    auction.announce_closed("item-1")
    assert sniper.shows_it_has_won_auction("item-1")

    auction.announce_closed("item-2")
    assert sniper.shows_it_has_won_auction("item-2")
  end

end
