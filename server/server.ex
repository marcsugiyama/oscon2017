defmodule Server do

def start() do
    Process.spawn(Server, :loop, [0], [])
end

def add(pid, incr) do
    send pid, {:incr, incr}
end

def get(pid) do
    send pid, {:get, self()}
    receive do
        {:count, count} ->
            count
    end
end

def loop(count) do
    receive do
        {:incr, incr} ->
            loop(count + incr)
        {:get, client} ->
            send client, {:count, count}
            loop(count)
        _ ->
            loop(count)
    end
end

end
