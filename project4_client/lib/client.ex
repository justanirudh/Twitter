defmodule Client do
    use GenServer
    #state: %{:hashtags => hashtags,:mentions => mentions,:num_users => num_users, :factor => factor, :engine_pid => engine_pid,
    #        :rank => rank, :userid => userid, :subscribers_size => length subscribers}

    def init(state) do
        {:ok, state}
    end

    #register
    def handle_call(:register, _from, state) do
        engine_pid = Map.get(state, :engine_pid)
        userid = GenServer.call(engine_pid, :register)
        {:reply, :ok, Map.put(state, :userid, userid) }
    end

    #subscribe with zipf distribution
    def handle_call(:subscribe, _from, state) do
        engine_pid = Map.get(state, :engine_pid)
        rank = Map.get(state, :rank)
        num_users = Map.get(state, :num_users)
        userid = Map.get(state, :userid)
        #get teirs
        teir1 = 0.2*num_users |> round
        teir2 = 0.4*num_users |> round
        teir3 = 0.6*num_users |> round
        teir4 = 0.8*num_users |> round
        #get num_subscribed to
        num_subscribed_to = cond do
            rank >= 0 && rank < teir1 -> teir1
            rank >= teir1 && rank < teir2 -> teir2
            rank >= teir2 && rank < teir3 -> teir3
            rank >= teir3 && rank < teir4 -> teir4
            rank >= teir4 && rank < num_users -> num_users   
        end
        #get all userids from engine and select 'num_subscribed_to' randomly from them
        GenServer.call(engine_pid, :get_all_users)
        |> Enum.map(fn(id_int) -> id_int |> Integer.to_string() |> String.to_atom() end ) #TODO: remove this after removing the hack 
        |> List.delete(userid) 
        |> Enum.take_random(num_subscribed_to)
        |> Enum.each(fn(subscribeToId) -> GenServer.call(engine_pid, {:subscribe, userid, subscribeToId}) end)
        {:reply, :ok, state }
    end

    def handle_call(:get_subscribers_size, _from, state) do
        engine_pid = Map.get(state, :engine_pid)
        userid = Map.get(state, :userid)
        subscribers = GenServer.call(engine_pid, {:get_all_subscribers, userid})
        IO.inspect length subscribers
        {:reply, :ok, Map.put(state, :subscribers_size, length subscribers)}
    end


    def handle_cast({:tweet, tweets, idx}, state) do
        
        {:noreply, state} 
    end

end