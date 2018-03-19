defmodule UiWeb.ChannelValuesChannel do
  use UiWeb, :channel

  def join("channel_values:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket
          |> assign(:topics, [])}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (channel_values:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
  def handle_in("watch", %{"app_name" => app_name ,"app_instance" => app_instance}, socket) do
    {:reply,:ok, put_new_topics(socket,["#{app_name}:#{app_instance}"])}
  end
    def handle_info({group,event,value},socket) do
    if group in socket.assigns.topics do
      push socket, "watch", %{group: group,event: event, value: value}
    end
    {:noreply, socket}
  end

  defp put_new_topics(socket, topics) do
    Enum.reduce(topics, socket, fn topic, acc ->
      topics = acc.assigns.topics
      if topic in topics do
        acc
      else
        :ok = Firmware.Common.subscribe(topic)
        assign(acc, :topics, [topic | topics])
      end
    end)
  end
  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
