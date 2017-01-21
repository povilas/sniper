defmodule SniperRunner.Client do
  use GenServer

  def start_link(listener, item, stop_price, name) do
    GenServer.start_link(__MODULE__, [listener, item, stop_price], name: name)
  end

  def init([listener, item, stop_price]) do
    {:ok, sniper} = :gen_tcp.connect('localhost', 8081, [:binary, packet: :line, active: :once])
    send_start(sniper, item, stop_price)
    {:ok, %{
      item: item,
      stop_price: stop_price,
      listener: listener,
      sniper: sniper
    }}
  end

  def handle_info({:tcp, sniper, "LOST" <> _}, %{sniper: sniper, listener: listener} = state) do
    :inet.setopts(sniper, [active: :once])
    send listener, {:sniper_shows_it_has_lost_auction, state.item}
    {:noreply, state}
  end

  def handle_info({:tcp, sniper, "I'M BIDDING" <> _}, %{sniper: sniper, listener: listener} = state) do
    :inet.setopts(sniper, [active: :once])
    send listener, {:sniper_shows_it_is_bidding, state.item}
    {:noreply, state}
  end

  def handle_info({:tcp, sniper, "I'M WINNING" <> _}, %{sniper: sniper, listener: listener} = state) do
    :inet.setopts(sniper, [active: :once])
    send listener, {:sniper_shows_it_is_winning, state.item}
    {:noreply, state}
  end

  def handle_info({:tcp, sniper, "I'M LOSING" <> msg}, %{sniper: sniper, listener: listener} = state) do
    :inet.setopts(sniper, [active: :once])
    [price, bid] = msg |> String.trim |> String.split(",")
    send listener, {:sniper_shows_it_is_losing, state.item, String.to_integer(price), String.to_integer(bid)}
    {:noreply, state}
  end

  def handle_info({:tcp, sniper, "WON" <> _}, %{sniper: sniper, listener: listener} = state) do
    :inet.setopts(sniper, [active: :once])
    send listener, {:sniper_shows_it_has_won_auction, state.item}
    {:noreply, state}
  end

  defp send_start(sniper, item, nil), do: :ok = :gen_tcp.send(sniper, "START sniper,#{item}\r\n")

  defp send_start(sniper, item, stop_price), do: :ok = :gen_tcp.send(sniper, "START sniper,#{item},#{stop_price}\r\n")

end

defmodule SniperRunner do
  use GenServer

  def start_link() do
    case Registry.start_link(:unique, SniperRunner.Registry) do
      {:error, {:already_started, pid}} ->
        Process.exit(pid, :kill)
        start_link()
      {:ok, _} ->
        GenServer.start_link(__MODULE__, self(), name: __MODULE__)
    end
  end

  def init(listener) do
    {:ok, %{
      listener: listener
    }}
  end

  def start_bidding(item, stop_price \\ nil), do: GenServer.call(__MODULE__, {:start_bidding, item, stop_price})

  def shows_it_has_lost_auction(item), do: Util.wait_for {:sniper_shows_it_has_lost_auction, item}

  def shows_it_is_bidding(item), do: Util.wait_for {:sniper_shows_it_is_bidding, item}

  def shows_it_is_winning(item), do: Util.wait_for {:sniper_shows_it_is_winning, item}

  def shows_it_is_losing(item, last_price, last_bid), do: Util.wait_for {:sniper_shows_it_is_losing, item, last_price, last_bid}

  def shows_it_has_won_auction(item), do: Util.wait_for {:sniper_shows_it_has_won_auction, item}

  def handle_call({:start_bidding, item, stop_price}, _from, state) do
    {:ok, _} = SniperRunner.Client.start_link(state.listener, item, stop_price, via(item))
    {:reply, :ok, state}
  end

  defp via(item), do: {:via, Registry, {SniperRunner.Registry, item}}

end
