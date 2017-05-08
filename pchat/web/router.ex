defmodule Pchat.Router do
  use Pchat.Web, :router

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

  scope "/", Pchat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Pchat do
    pipe_through :api
    resources "/post", PostController
  end
end
