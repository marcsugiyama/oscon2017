defmodule Pchat.PageController do
  use Pchat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
