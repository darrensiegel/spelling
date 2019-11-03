defmodule SpellingWeb.Router do
  use SpellingWeb, :router

  alias SpellingWeb.Router.Helpers, as: Routes

  defp fetch_user_token(conn, _) do
    conn
    |> assign(:user, get_session(conn, :user))
  end

  defp redirect_to_login(conn, _) do
    case get_session(conn, :user) do
      nil -> redirect(conn, to: Routes.page_path(conn, :index))
      _ -> conn
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_user_token
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_user_token
    plug :redirect_to_login
  end

  pipeline :api do
    plug :accepts, ["text"]
  end

  scope "/", SpellingWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/", SpellingWeb do
    pipe_through :protected

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
