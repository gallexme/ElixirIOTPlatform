defmodule UiWeb.AppsController do
  use UiWeb, :controller

  def get_php_apps() do
    Path.wildcard(AppSystem.Discovery.get_apps_path() <> "/*.php")
    |> Enum.map(fn appname ->
      {Path.basename(appname), appname, "todo"}
    end)
  end

  def index(conn, _params) do
    apps = Application.loaded_applications() ++ get_php_apps()
    # |>Enum.filter(fn e ->
    #   {atom, name, version} = e
    #   IO.puts "CHECKING "<>to_string name
    #   case Application.spec(atom,:mod) do
    #     [] -> false
    #     {module, _dunno} ->
    #       #IO.inspect module
    #       Enum.member?((module.module_info[:attributes][:behaviour]), AppBehavior)
    #       end
    # end)
    render(conn, "index.html", apps: apps)
  end

  def php(conn, _params) do
    alias Porcelain.Result

    %Result{out: output, status: status} =
      Porcelain.shell("php " <> AppSystem.Discovery.get_apps_path() <> "/test_php/app.php")

    render(conn, "php.html", result: output)
  end
end
