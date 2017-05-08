defmodule Pchat.RoomChannel do
  use Pchat.Web, :channel

  def post(pid, user, img) do
    send(pid, {:post, user, img})
  end

  def join("room:lobby", _payload, socket) do
    Pchat.PostHandler.register(self())
    {:ok, socket}
  end

  def handle_in("new:msg", payload, socket) do
    broadcast! socket, "new:msg", %{user: payload["user"], body: payload["body"]}
    {:noreply, socket}
  end

  def handle_info({:post, user, img}, socket) do
    push socket, "new:msg", %{user: user, body: img}
    {:noreply, socket}
  end
end
