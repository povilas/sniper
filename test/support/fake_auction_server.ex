defmodule FakeAuctionServer do
  require Logger
  use GenServer

  def start_link(), do: GenServer.start_link(__MODULE__, self(), name: __MODULE__)

  def init(listener) do
    {:ok, %{
      listener: listener,
      socket: nil,
      client: nil
    }}
  end

  def start_selling_item(), do: GenServer.cast(__MODULE__, :start_selling_item)

  def announce_closed(), do: GenServer.call(__MODULE__, :announce_closed)

  def report_price(price, increment, bidder), do: GenServer.call(__MODULE__, {:report_price, price, increment, bidder})

  def has_received_join_request_from(bidder), do: Util.wait_for {:auction_has_received_join_request_from, bidder}

  def has_received_bid(price, _), do: Util.wait_for {:auction_has_received_bid, price}

  def handle_cast(:start_selling_item, state) do
    {:ok, socket} = :gen_tcp.listen(8080, [:binary, packet: :line, active: :once, reuseaddr: true])
    Logger.info "FakeAuctionServer listening on 8080"
    {:ok, client} = :gen_tcp.accept(socket)
    {:noreply, %{state | socket: socket, client: client}}
  end

  def handle_call({:report_price, price, increment, bidder}, _from, state) do
    :ok = :gen_tcp.send(state.client, "PRICE #{price},#{increment},#{bidder}\r\n")
    {:reply, :ok, state}
  end

  def handle_call(:announce_closed, _from, state) do
    :ok = :gen_tcp.send(state.client, "CLOSE\r\n")
    {:reply, :ok, state}
  end

  def handle_info({:tcp, _from, "JOIN" <> msg}, state) do
    bidder = msg |> String.trim
    :inet.setopts(state.client, [active: :once])
    send state.listener, {:auction_has_received_join_request_from, bidder}
    {:noreply, state}
  end

  def handle_info({:tcp, _from, "BID" <> msg}, state) do
    price = msg |> String.trim |> String.to_integer
    :inet.setopts(state.client, [active: :once])
    send state.listener, {:auction_has_received_bid, price}
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect msg
    :inet.setopts(state.client, [active: :once])
    {:noreply, state}
  end

end
