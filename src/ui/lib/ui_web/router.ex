defmodule UiWeb.Router do
  use UiWeb, :router
  if Mix.env == :dev do
    use Plug.ErrorHandler
    use Sentry.Plug
  end
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UiWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/apps/php", AppsController, :php

    resources "/apps", AppsController
  end

  # Other scopes may use custom stacks.
  # scope "/api", UiWeb do
  #   pipe_through :api
  # end
end
