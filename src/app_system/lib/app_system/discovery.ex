defmodule AppSystem.Discovery do
  @moduledoc false
  use GenServer

  def start_link() do
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

  def get_native_apps_with_releases(folders) do
    folders
    |> Enum.filter(fn app_path ->
      File.exists?(app_path <> "/releases/RELEASES")
    end)
  end

  def get_native_apps do
    require Logger
    Path.wildcard(get_apps_path() <> "/*/")
    |> get_native_apps_with_releases
    |> Enum.map(fn app_path ->
      {:ok, release_data} = :file.consult(String.to_charlist(app_path <> "/releases/RELEASES"))

      cond do
        Enum.empty?(release_data)  ->
          Logger.error("Non Valid Native App Release File: "<> app_path <> "/releases/RELEASES")
          nil

        true ->
          {app_path,
           Enum.at(release_data, 0)
           |> Enum.at(0)}
      end
    end)
  end

  def get_beam_files(app_path, path) do
    Path.wildcard(to_string(app_path) <> to_string(path <> "/ebin/*.beam"))
  end

  def update_deps(app_path, deps) do

    Enum.map(deps, fn dep ->
      {dep_name, dep_version, path} = dep
      path = Regex.replace(~r/-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/,to_string(path),"") |>String.replace_prefix(".", "") # version entfernen
     # IO.inspect "DEP PATH:"<>path
      dep_version = to_string(dep_version)
      current_version = to_string(Application.spec(dep_name, :vsn))
     # IO.inspect "VERSIONS current:"<>current_version<>" dep:"<> dep_version
      case dep_needs_upgrade(current_version, dep_version) do
        :upgrade ->
          get_beam_files(app_path, path)
          |> Enum.map(fn e -> Path.rootname(e) end)
          |> Enum.map(fn e ->
            :code.add_path(String.to_charlist(Path.dirname(e)))
            basename = Path.basename(e)

            %{
              :beam_name => basename,
              :delete => :code.delete(String.to_atom(basename)),
              :purge => :code.purge(String.to_atom(basename)),
              :module => :code.load_file(String.to_atom(basename)),
              :path => String.to_charlist(e)
            }
          end)

        :nothing ->
          []
      end
    end)
    |> Enum.filter(fn e ->
      length(e) > 0
    end)
  end

  def discover_native_apps() do
    get_native_apps()
    |>Enum.filter(fn app -> app != nil end)
    |> Enum.map(fn app ->
      {app_path, {:release, app_name, version, erl_version, deps, restart_type}} = app
      updated_deps = update_deps(app_path, deps)

      IO.inspect :application.ensure_all_started(String.to_atom(to_string(app_name)))

      %{
        app_name: app_name,
        version: version,
        erl_version: erl_version,
        updated_deps: updated_deps,
        restart_type: restart_type
      }
    end)
  end

  def discover_php_apps() do
    Path.wildcard(get_apps_path() <> "/**/app.php")
  end


  def handle_info(:heartbeat, state) do
    # IO.puts("HELLO")
    apps = discover_native_apps() ++ discover_php_apps()
    Firmware.Common.broadcast({"app_system_discovery:1", :new_apps_list, apps})
    schedule_next_heartbeat()
    {:noreply, state}
  end

  def handle_call(_msg, state) do
    {:ok, :ok, state}
  end
end

