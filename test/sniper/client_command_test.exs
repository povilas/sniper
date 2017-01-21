defmodule Sniper.ClientCommandTest do

  use ExUnit.Case
  import Sniper.ClientCommand, only: [decode: 1]
  alias Sniper.ClientCommand.Start

  test "decode start" do
    assert decode("START name,item\r\n") == %Start{id: "name", item: "item", price: :undefined}
    assert decode("START name,item,20\r\n") == %Start{id: "name", item: "item", price: 20}
  end

end
