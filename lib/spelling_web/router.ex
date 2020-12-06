defmodule SpellingWeb.Router do
  use SpellingWeb, :router

  alias SpellingWeb.Router.Helpers, as: Routes

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {SpellingWeb.LayoutView, "root.html"}
    plug :put_layout, {SpellingWeb.LayoutView, "app.html"}
  end

  pipeline :api do
    plug :accepts, ["text"]
  end

  scope "/", SpellingWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/test", TestLive
    live "/lists/:user", ListsLive
    live "/details/:id", DetailsLive
    live "/quiz/:id/mcq", MultipleChoiceLive
    live "/quiz/:id/spelling", SpellLive
  end

  # Other scopes may use custom stacks.
  scope "/api", SpellingWeb do
    pipe_through :api

    get "/clip/:id", ClipController, :get
  end
end
