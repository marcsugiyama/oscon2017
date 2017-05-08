defmodule Pchat.RoomChannel do
  use Pchat.Web, :channel

  def join("room:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new:msg", payload, socket) do
    broadcast! socket, "new:msg", %{user: payload["user"], body: payload["body"]}
    {:noreply, socket}
  end
end
