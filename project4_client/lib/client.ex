defmodule Client do
    use GenServer
    #state: %{:hashtags => hashtags,:mentions => mentions,:num_users => num_users, :zipf_factor => zipf_factor, :engine_pid => engine_pid,
    #        :rank => rank, :userid => userid, :subscribers_size => length subscribers}


    def tweet_see(tweets, tweets_len, idx, wait_time, engine_pid, userid) do
        tweet_content = "Tweet" <> Integer.to_string(userid) <>  " " <> Enum.at(tweets, idx)
        :ok = GenServer.call(engine_pid, {:tweet, userid, tweet_content}, :infinity)
        IO.inspect Integer.to_string(userid) <> " tweeted " <> tweet_content
        :timer.sleep (wait_time |> round)  # wait_time is in milliseconds
        tweet_see(tweets, tweets_len, rem(idx + 1, tweets_len), wait_time, engine_pid, userid)
    end

    def tweet_nosee(tweets, tweets_len, idx, wait_time, engine_pid, userid) do
        tweet_content = Enum.at(tweets, idx)
        :ok = GenServer.call(engine_pid, {:tweet, userid, tweet_content}, :infinity)
        :timer.sleep (wait_time |> round)  # wait_time is in milliseconds
        tweet_nosee(tweets, tweets_len, rem(idx + 1, tweets_len), wait_time, engine_pid, userid)
    end

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
    #TODO: change this: make zipf law compliant
    # def handle_call(:subscribe, _from, state) do
    #     engine_pid = Map.get(state, :engine_pid)
    #     rank = Map.get(state, :rank)
    #     num_users = Map.get(state, :num_users)
    #     userid = Map.get(state, :userid)
    #     #get teirs
    #     teir1 = 0.2*num_users |> round
    #     teir2 = 0.4*num_users |> round
    #     teir3 = 0.6*num_users |> round
    #     teir4 = 0.8*num_users |> round
    #     #get num_subscribed to
    #     num_subscribed_to = cond do
    #         rank >= 0 && rank < teir1 -> teir1
    #         rank >= teir1 && rank < teir2 -> teir2
    #         rank >= teir2 && rank < teir3 -> teir3
    #         rank >= teir3 && rank < teir4 -> teir4
    #         rank >= teir4 && rank < num_users -> num_users   
    #     end
    #     #get all userids from engine and select 'num_subscribed_to' randomly from them
    #     GenServer.call(engine_pid, :get_all_users)
    #     |> List.delete(userid) 
    #     |> Enum.take_random(num_subscribed_to)
    #     |> Enum.each(fn(subscribeToId) -> GenServer.call(engine_pid, {:subscribe, userid, subscribeToId}) end)
    #     {:reply, :ok, state }
    # end

    # #get subscriber size
    # def handle_call(:get_subscribers_size, _from, state) do
    #     engine_pid = Map.get(state, :engine_pid)
    #     userid = Map.get(state, :userid)
    #     subscribers = GenServer.call(engine_pid, {:get_all_subscribers, userid})
    #     IO.inspect length subscribers
    #     {:reply, :ok, Map.put(state, :subscribers_size, length subscribers)}
    # end

    #tweet
    def handle_cast({:tweet, tweets, idx,see}, state) do
        engine_pid = Map.get(state, :engine_pid)
        rank = Map.get(state, :rank)
        num_users = Map.get(state, :num_users)
        userid = Map.get(state, :userid)
        zipf_factor = Map.get(state, :zipf_factor)

        #wait_time b/w tweets
        wait_time = cond do
            rank >= 0 && rank < (0.2 * num_users |> round) -> (zipf_factor * 0.2) |> round
            true -> (zipf_factor * 0.8) |> round
        end

        tweets_len = length tweets
        if (see == :see_tweets) do
            Task.start(Client, :tweet_see, [tweets, tweets_len, rem(idx, tweets_len), wait_time, engine_pid, userid])     
        else
            Task.start(Client, :tweet_nosee, [tweets, tweets_len, rem(idx, tweets_len), wait_time, engine_pid, userid])     
        end
        
        
        {:noreply, state} 
    end

end