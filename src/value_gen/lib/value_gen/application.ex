defmodule ValueGen.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: ValueGen.Worker.start_link(arg)
       {ValueGen.Worker, ""},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ValueGen.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
defmodule ValueGen.Worker do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    IO.puts("WOW SUCH APP NEW")
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 2* 1000) # In 2 hours
  end
end
