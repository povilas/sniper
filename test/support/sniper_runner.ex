defmodule SniperRunner do
  use GenServer

  def start_link(), do: GenServer.start_link(__MODULE__, self(), name: __MODULE__)

  def init(listener) do
    {:ok, sniper} = :gen_tcp.connect('localhost', 8081, [:binary, packet: :line, active: :once])
    {:ok, %{
      listener: listener,
      sniper: sniper
    }}
  end

  def start_bidding(), do: GenServer.call(__MODULE__, :start_bidding)

  def shows_sniper_has_lost_auction(), do: Util.wait_for :sniper_shows_sniper_has_lost_auction

  def showns_it_is_bidding(), do: Util.wait_for :sniper_shows_it_is_bidding

  def handle_call(:start_bidding, _from, state) do
    :ok = :gen_tcp.send(state.sniper, "START\r\n")
    {:reply, :ok, state}
  end

  def handle_info({:tcp, sniper, "LOST" <> _}, %{sniper: sniper, listener: listener} = state) do
    :inet.setopts(sniper, [active: :once])
    send listener, :sniper_shows_sniper_has_lost_auction
    {:noreply, state}
  end

  def handle_info({:tcp, sniper, "I'M BIDDING" <> _}, %{sniper: sniper, listener: listener} = state) do
    :inet.setopts(sniper, [active: :once])
    send listener, :sniper_shows_it_is_bidding
    {:noreply, state}
  end
end
