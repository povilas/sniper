defmodule Sniper.ClientCommand do

  defmodule Start, do: defstruct []

  def decode("START" <> _) do
    %Start{}
  end

end
