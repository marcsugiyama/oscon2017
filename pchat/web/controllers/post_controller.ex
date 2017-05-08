defmodule Pchat.PostController do
  use Pchat.Web, :controller

  def index(conn, %{"user" => user, "img" => img}) do
    status = Pchat.PostHandler.post(user, img)
    json conn, %{"status": status}
  end
end
