defmodule SniperRunner.Client do
  use GenServer

  def start_link(listener, item, name) do
    GenServer.start_link(__MODULE__, [listener, item], name: name)
  end

  def init([listener, item]) do
    {:ok, sniper} = :gen_tcp.connect('localhost', 8081, [:binary, packet: :line, active: :once])
    :ok = :gen_tcp.send(sniper, "START\r\n")
    {:ok, %{
      listener: listener,
      item: item,
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

  def handle_info({:tcp, sniper, "WON" <> _}, %{sniper: sniper, listener: listener} = state) do
    :inet.setopts(sniper, [active: :once])
    send listener, {:sniper_shows_it_has_won_auction, state.item}
    {:noreply, state}
  end

end

defmodule SniperRunner do
  use GenServer

  def start_link() do
    case Registry.start_link(:unique, SniperRunner.Registry) do
      {:error, {:already_started, pid}} ->
        Process.exit(pid, :kill)
        :timer.sleep(100)
        {:ok, _} = Registry.start_link(:unique, SniperRunner.Registry)
      {:ok, _} -> :ok
    end

    GenServer.start_link(__MODULE__, self(), name: __MODULE__)
  end

  def init(listener) do
    {:ok, %{
      listener: listener
    }}
  end

  def start_bidding(item), do: GenServer.call(__MODULE__, {:start_bidding, item})

  def shows_it_has_lost_auction(item), do: Util.wait_for {:sniper_shows_it_has_lost_auction, item}

  def shows_it_is_bidding(item), do: Util.wait_for {:sniper_shows_it_is_bidding, item}

  def shows_it_is_winning(item), do: Util.wait_for {:sniper_shows_it_is_winning, item}

  def shows_it_has_won_auction(item), do: Util.wait_for {:sniper_shows_it_has_won_auction, item}

  def handle_call({:start_bidding, item}, _from, state) do
    {:ok, _} = SniperRunner.Client.start_link(state.listener, item, via(item))
    {:reply, :ok, state}
  end

  defp via(item), do: {:via, Registry, {SniperRunner.Registry, item}}

end
