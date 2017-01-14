defmodule Sniper.ClientCommandTest do

  use ExUnit.Case
  import Sniper.ClientCommand, only: [decode: 1]
  alias Sniper.ClientCommand.Start

  test "decode start" do
    assert decode("START\r\n") == %Start{}
  end

end
