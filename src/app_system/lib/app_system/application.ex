defmodule AppSystem.Discovery do
  @moduledoc false
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, %{})
  end

  # Callbacks
  def get_apps_path() do
    is_nerves = Code.ensure_compiled?(Nerves.Runtime)

    cond do
      # wenn Nerves Projekt
      is_nerves ->
        System.user_home()
      not is_nerves ->
        System.cwd!() <> "/../../installed_apps"
    end
  end

  def init(_opts) do
    schedule_next_heartbeat()
    {:ok, %{apps: []}}
  end

  defp schedule_next_heartbeat() do
    # 60 * 60 * 1000) # In 60 min
    Process.send_after(self(), :heartbeat, 1000)
  end

  defp dep_needs_upgrade(current_version, new_version) do
    if current_version === "" do
      current_version = "0.0.1"
    end

    if new_version === "" do
      new_version = "0.0.1"
    end

    current_version =
      case Version.parse(current_version) do
        {:ok, version} -> version
        :error -> Version.parse!(current_version <> ".0")
      end

    new_version =
      case Version.parse(new_version) do
        {:ok, version} -> version
        :error -> Version.parse!(new_version <> ".0")
      end

    job =
      case Version.compare(current_version, new_version) do
        :lt ->
          :upgrade

        :gt ->
          :nothing

        :eq ->
          :nothing
      end

    job
  end

  defp discover_apps() do
    Path.wildcard(get_apps_path() <> "/*/")
    |> Enum.map(fn app_path ->
      Path.wildcard(app_path <> "/releases/RELEASES")
      |> Enum.map(fn e ->
        {:ok, release_data} = :file.consult(String.to_char_list(e))

        Enum.at(release_data, 0)
        |> Enum.at(0)
      end)
      |> Enum.map(fn app ->
        {:release, app_name, version, erl_version, deps, restart_type} = app

        modules =
          Enum.map(deps, fn dep ->
            {dep_name, dep_version, path} = dep
            path = String.replace_prefix(to_string(path), ".", "")
            dep_version = to_string(dep_version)
            current_version = to_string(Application.spec(dep_name, :vsn))

            case dep_needs_upgrade(current_version, dep_version) do
              :upgrade ->
                Path.wildcard(to_string(app_path) <> to_string(path <> "/ebin/*.beam"))
                |> Enum.map(fn e -> Path.rootname(e) end)
                |> Enum.map(fn e ->
                  :code.add_path(String.to_char_list(Path.dirname(e)))
                  # IO.puts "PATH:"<>Path.dirname(e)
                  %{
                    :beam_name => Path.basename(e),
                    :delete => :code.delete(String.to_atom(Path.basename(e))),
                    :purge => :code.purge(String.to_atom(Path.basename(e))),
                    :module => :code.load_file(String.to_atom(Path.basename(e))),
                    :path => String.to_charlist(e)
                  }
                end)

              # IO.puts "NO NEED TO UPDATE/INSTALL "<>to_string dep_name
              :nothing ->
                []
            end
          end)
          |> Enum.filter(fn e -> length(e) > 0 end)

        :application.ensure_all_started(String.to_atom(to_string(app_name)))
        {:release, app_name, version, erl_version, modules, restart_type}
      end)

      # |>IO.inspect
    end)

    # |>Enum.each(fn e-> IO.inspect e end)
  end

  def handle_info(:heartbeat, state) do
    IO.puts("HELLO")
    discover_apps()
    schedule_next_heartbeat()
    {:noreply, state}
  end

  def handle_call(_msg, state) do
    {:ok, :ok, state}
  end
end

defmodule AppSystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: AppSystem.Worker.start_link(arg)
      {AppSystem.Discovery, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AppSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
