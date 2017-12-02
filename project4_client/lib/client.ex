defmodule Client do
    use GenServer
    #state: rank, [#], [@], total_clients, factor, master_pid

    def init(state) do
        {:ok, state}
    end



end