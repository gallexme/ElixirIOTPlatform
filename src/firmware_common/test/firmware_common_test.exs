defmodule Firmware.CommonTest do
  use ExUnit.Case
  doctest Firmware.Common
  setup do
  Phoenix.PubSub.PG2.start_link(Firmware.Common.PubSub,[])
   {:ok,server_pid} = TestServer.start_link("foo")
    {:ok,server: server_pid}
  end
  test "greets the world" do
    assert Firmware.Common.hello() == :world
  end
end

defmodule TestServer do
  use GenServer
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end
  def init(opts) do
    :ok = Firmware.Common.subscribe("transfers")
    :ok = Firmware.Common.subscribe("stats")

    :ok = Firmware.Common.subscribe("all")
    {:ok, opts}
  end
   def handle_info({"all", event, value}, state) do
    IO.puts "Received Event:#{inspect event} Value:#{inspect value}"
    {:noreply, state}
  end

end
