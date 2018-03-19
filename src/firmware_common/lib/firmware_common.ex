defmodule Firmware.Common do
  @spec subscribe() :: :ok | {:error, term}
  def subscribe do
    subscribe "all"
  end

  @spec subscribe(binary)  :: :ok | {:error, term}
  def subscribe(group) do
    Phoenix.PubSub.subscribe(Firmware.Common.PubSub, group)
  end


  def broadcast({group, event, term}) do
    Phoenix.PubSub.broadcast(Firmware.Common.PubSub, group, {group, event, term})
    Phoenix.PubSub.broadcast(Firmware.Common.PubSub, "all", {group, event, term})
  end
end
