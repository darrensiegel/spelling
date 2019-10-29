defmodule SpellingWeb.Router do
  use SpellingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phoenix.LiveView.Flash
  end

  pipeline :api do
    plug :accepts, ["text"]
  end

  scope "/", SpellingWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/lists", ListsLive
    live "/lists/:id", DetailsLive
    live "/lists/:id/quiz", MultipleChoiceLive
  end

  # Other scopes may use custom stacks.
  scope "/api", SpellingWeb do
    pipe_through :api

    get "/clip/:id", ClipController, :get
  end
end
