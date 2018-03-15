defmodule UiWeb.AppsController do
  use UiWeb, :controller

  def index(conn, _params)do
    apps = Application.loaded_applications
    #|>Enum.filter(fn e ->
    #   {atom, name, version} = e
    #   IO.puts "CHECKING "<>to_string name
    #   case Application.spec(atom,:mod) do
    #     [] -> false
    #     {module, _dunno} ->
    #       #IO.inspect module
    #       Enum.member?((module.module_info[:attributes][:behaviour]), AppBehavior)
    #       end
    # end)
    render conn, "index.html", apps: apps
  end

end
