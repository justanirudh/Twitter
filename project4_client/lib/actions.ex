defmodule Actions do

    defp loop do
        :timer.sleep(1000000000)
        loop
    end

    defp print_tweet_rate() do
        prev = System.monotonic_time(:microsecond) #start timer
        receive do
          {:print, num_tweets} ->
            next = System.monotonic_time(:microsecond)
            time_taken = next - prev
            IO.inspect "num_tweets: #{num_tweets}"
            IO.inspect "time taken: #{time_taken}"
            rate = (num_tweets/time_taken) * 1000000
            IO.inspect "tweet-rate = #{rate} per second"
        end
        print_tweet_rate()
    end

    def make_em_tweet(num_users, client_pids, tweets, see) do
        0..num_users-1 |> Enum.each(fn(idx) -> GenServer.cast(Enum.at(client_pids, idx), {:tweet, tweets, idx, see}) end )
    end

    def subscribe_to(userId, subscribeToId, engine_pid) do
        GenServer.call(engine_pid, {:subscribe, userId, subscribeToId})   
    end

    def get_sample_hashtags(engine_pid) do
        GenServer.call(engine_pid, {:hashtag, :getkeys})
    end

    def get_tweets_with_hashtag(hashtag, engine_pid) do
        IO.inspect hashtag
        GenServer.call(engine_pid, {:hashtag, :hashtag, hashtag})
    end

    def get_sample_mentions(engine_pid) do
        GenServer.call(engine_pid, {:mention, :getkeys})
    end

    def get_tweets_with_mention(mention, engine_pid) do
        GenServer.call(engine_pid, {:mention, :mention, mention})
    end

    def get_feed(userid, engine_pid) do
        GenServer.call(engine_pid, {:feed, userid})
    end

    def simulate(engine_pid, num_users, see) do
        zipf_factor = 100/1000 #(factor / fraction of a millisecond wait time) 
        print_every_factor = 3
        hashtags_size = 1000
        mentions_size = 1000
        tweets_size = 8000
    
        #register client-master
        client_master_pid = self()
        :ok = GenServer.call(engine_pid, {:register_client_master, client_master_pid, num_users * print_every_factor})
        
        #prepare hashtags, mentions, tweets
        hashtags = Utils.get_hashtags(0, hashtags_size, [])
        mentions = Utils.get_mentions(hashtags_size, hashtags_size + mentions_size, [])
        tweets = Utils.get_tweets(hashtags_size + mentions_size,hashtags_size + mentions_size + tweets_size, hashtags, hashtags_size,mentions, mentions_size,[], true, false, 0, 0)
    
        #start users
        state = %{:hashtags => hashtags,
        :mentions => mentions,
        :num_users => num_users, 
        :zipf_factor => zipf_factor, 
        :engine_pid => engine_pid}

        IO.inspect "Spawning all users"
    
        client_pids = 0..num_users-1 |> Enum.map(fn(rank) -> GenServer.start_link(Client, Map.put(state, :rank, rank) ) |> elem(1)  end)
    
        IO.inspect "Registering all users"

        #register all users
        Enum.each(client_pids, fn(pid) -> GenServer.call(pid, :register) end )
    
        IO.inspect "Registered all users"
        
        #make clients subscribe by zipf (power law)
        # Enum.each(client_pids, fn(pid) -> GenServer.call(pid, :subscribe) end )
    
        # IO.inspect "Created zipf distribution of subscription model"
    
        #populate subscribers size for each client to simulate zipf distribution for tweets
        # Enum.each(client_pids, fn(pid) -> GenServer.call(pid, :get_subscribers_size) end )
        
        #make clients tweet by zipf law (80-20)
        Task.start(Actions, :make_em_tweet, [num_users, client_pids, tweets, see])

        IO.inspect "Users have started tweeting"
    
        if(see == :see_tweet_rate) do
            IO.inspect "Waiting for first tweet-rate-results to arrive"
            print_tweet_rate()
        else
            #loop infinitely
            loop()
        end

    end
end