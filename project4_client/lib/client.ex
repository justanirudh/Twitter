defmodule Client do
    use GenServer
    #state: rank, [#], [@], total_clients, factor, master_pid, userid

    def init(state) do
        {:ok, state}
    end

    #register
    def handle_call(:register, _from, state) do
        engine_pid = elem(state, 5)
        userid = GenServer.call(engine_pid, :register)
        IO.inspect userid
        {:reply, :ok, Tuple.append(state, userid) }
    end



end