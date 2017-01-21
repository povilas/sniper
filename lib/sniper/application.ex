defmodule Sniper.Application do

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ClientAcceptor, [])
    ]

    opts = [strategy: :one_for_one, name: Sniper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
