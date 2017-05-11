defmodule Server do

def start() do
    pid = Process.spawn(Server, :loop, [0], [])
    Process.register(pid, :server)
end

def add(incr) do
    send :server, {:incr, incr}
end

def get() do
    send :server, {:get, self()}
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
