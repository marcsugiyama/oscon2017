defmodule Pchat.PostHandler do
use GenServer

def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
end

def init([]) do
    {:ok, []}
end

def register(pid) do
    GenServer.cast(__MODULE__, {:register, pid})
end

def handle_cast({:register, pid}, pids) do
    Process.monitor pid
    {:noreply, [pid | pids]}
end

def post(user, img_url) do
    GenServer.call(__MODULE__, {:post, user, img_url})
end

def handle_call({:post, _user, _img_url}, _from, []) do
    {:reply, "no_room", []}
end

def handle_call({:post, user, img_url}, _from, pids) do
    postfn = fn pid -> Pchat.RoomChannel.post(pid, user, img_url) end
    Enum.each(pids, postfn)
    {:reply, "ok", pids}
end

def handle_info({:DOWN, _ref, :process, pid, _}, pids) do
    pids = Enum.filter(pids, &(&1 != pid))
    {:noreply, pids}
end

end
