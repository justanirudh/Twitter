defmodule Client do
    use GenServer
    #state: %{:hashtags => hashtags,:mentions => mentions,:num_users => num_users, :factor => factor, :engine_pid => engine_pid,
    #        :rank => rank, :userid => userid, :user_pids => user_pids}

    def init(state) do
        {:ok, state}
    end

    #register
    def handle_call(:register, _from, state) do
        engine_pid = Map.get(state, :engine_pid)
        userid = GenServer.call(engine_pid, :register)
        {:reply, :ok, Map.put(state, :userid, userid) }
    end

    #add all users except self
    def handle_call({:add_user_pids, user_pids}, _from, state) do
        IO.inspect user_pids
        {:reply, :ok, Map.put(state, :user_pids, user_pids) }
    end

    #subscribe
    def handle_call(:subcribe, _from, state) do
        engine_pid = Map.get(state, :engine_pid)
        rank = Map.get(state, :rank)
        num_users = Map.get(state, :num_users)
        num_subscribed_to = cond do
            rank >= 0 && rank < 0.2*num_users -> 0.2*num_users
            rank >= 0.2*num_users && rank < 0.4*num_users -> 0.4*num_users
            rank >= 0.4*num_users && rank < 0.6*num_users -> 0.6*num_users
            rank >= 0.6*num_users && rank < 0.8*num_users -> 0.8*num_users
            rank >= 0.8*num_users && rank < num_users -> num_users   
        end
        #subscribe to num_subscribed_to number of clients

        userid = GenServer.call(engine_pid, :register)
        IO.inspect userid
        {:reply, :ok, Tuple.append(state, userid) }
    end

end