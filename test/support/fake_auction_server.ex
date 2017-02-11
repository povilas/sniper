defmodule FakeAuctionServer.Client do
  require Logger
  use GenServer

  def start_link(listener, socket, item, name) do
    GenServer.start_link(__MODULE__, [listener, socket, item], name: name)
  end

  def init([listener, socket, item]) do
    send self(), :accept_client
    {:ok, %{
      item: item,
      listener: listener,
      socket: socket,
      client: nil
    }}
  end

  def handle_call({:report_price, price, increment, bidder}, _from, state) do
    :ok = :gen_tcp.send(state.client, "PRICE #{price},#{increment},#{bidder}\r\n")
    {:reply, :ok, state}
  end

  def handle_call(:announce_closed, _from, state) do
    :ok = :gen_tcp.send(state.client, "CLOSE\r\n")
    {:reply, :ok, state}
  end

  def handle_info(:accept_client, state) do
    {:ok, client} = :gen_tcp.accept(state.socket)
    :inet.setopts(client, [active: :once])
    {:noreply, %{state | client: client}}
  end

  def handle_info({:tcp, _from, "JOIN" <> msg}, state) do
    bidder = msg |> String.trim
    :inet.setopts(state.client, [active: :once])
    send state.listener, {:auction_has_received_join_request_from, state.item, bidder}
    {:noreply, state}
  end

  def handle_info({:tcp, _from, "BID" <> msg}, state) do
    price = msg |> String.trim |> String.to_integer
    :inet.setopts(state.client, [active: :once])
    send state.listener, {:auction_has_received_bid, state.item, price}
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warn("FakeAuctionServer got unhandled message #{inspect msg}")
    :inet.setopts(state.client, [active: :once])
    {:noreply, state}
  end

end


defmodule FakeAuctionServer do

  require Logger
  use GenServer

  def start_link() do
    case Registry.start_link(:unique, FakeAuction.Registry) do
      {:error, {:already_started, pid}} ->
        Process.exit(pid, :kill)
        start_link()
      {:ok, _} ->
        GenServer.start_link(__MODULE__, self(), name: __MODULE__)
    end
  end

  def start_selling_item(item), do: GenServer.cast(__MODULE__, {:start_selling_item, item})

  def announce_closed(item), do: GenServer.call(via(item), :announce_closed)

  def report_price(item, price, increment, bidder), do: GenServer.call(via(item), {:report_price, price, increment, bidder})

  def has_received_join_request_from(item, bidder), do: Util.wait_for {:auction_has_received_join_request_from, item, bidder}

  def has_received_bid(item, price, _), do: Util.wait_for {:auction_has_received_bid, item, price}

  def init(listener) do
    {:ok, socket} = :gen_tcp.listen(8080, [:binary, packet: :line, active: false, reuseaddr: true])
    {:ok, %{
      socket: socket,
      listener: listener
    }}
  end

  def handle_cast({:start_selling_item, item}, state) do
    {:ok, _} = FakeAuctionServer.Client.start_link(state.listener, state.socket, item, via(item))
    {:noreply, state}
  end

  defp via(item), do: {:via, Registry, {FakeAuction.Registry, item}}

end
