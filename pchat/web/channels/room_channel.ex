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
    user = payload["user"]
    body = payload["body"]
    changeset = Pchat.Msg.changeset(%Pchat.Msg{}, %{who: user, msg: body})
    {:ok, _} = Repo.insert(changeset)
    broadcast! socket, "new:msg", %{user: user, body: body}
    {:noreply, socket}
  end

  def handle_info({:post, user, img}, socket) do
    push socket, "new:msg", %{user: user, body: img}
    {:noreply, socket}
  end
end
