defmodule Engine do
    use GenServer
    @feed_lim 20
    #state: {curr_user_id, curr_tweet_id}

    #TODO: spawn every task to a new 'Task' to not make engine the bottleneck?: for tweet, hashtag, mention and feed
    #TODO remove inspects
    #TODO global counters for tweet, hashtag, mention and feed and calculate rates per sec (in real time)

    defp get_hashtags(tweet) do
        (String.split tweet) |> Enum.filter(fn(str) -> String.starts_with? str, "#" end)
    end

    defp get_mentions(tweet) do
        (String.split tweet) |> Enum.filter(fn(str) -> String.starts_with? str, "@" end)
    end

    defp get_latest_tweets(tweetIds) do
        #list of (tweets,timestamps)
        #arrange in decreasing order of timestamps
        #get first @feed_lim tweets
        Enum.map(tweetIds, fn(tweetId) -> GenServer.call(:tt, {:get, tweetId}) end) 
        |> (Enum.sort_by &(elem(&1, 1)), &>=/2) 
        |> Enum.take(@feed_lim)
        |> Enum.map(fn({tw,_}) -> tw end)
    end

    def init(state) do
        #epmd -daemon
        {:ok, _} = Node.start(String.to_atom("engine@127.0.0.1"))
        Application.get_env(:p4, :cookie) |> Node.set_cookie
        {:ok, state}
    end

    #register - tested
    def handle_call(:register, _from, state) do
        curr_user_id_int = elem(state, 0)
        curr_user_id = curr_user_id_int |> Integer.to_string() |> String.to_atom()
        IO.inspect "registering user with id #{curr_user_id}"
        :ok = GenServer.call(:uss, {:insert, curr_user_id})
        {:reply, curr_user_id, {curr_user_id_int + 1, elem(state, 1) } } #reply their userid to client
    end

    #feed-tested
    def handle_call({:feed, userId}, _from, state) do
        #list of userids
        subscribed_to_list = GenServer.call(:uss, {:get, :subscribed_to, userId})
        #list of tweetids
        tweetIds = Enum.flat_map(subscribed_to_list, fn(userId) -> GenServer.call(:ut, {:get, userId}) end)
        #list of tweets
        tweets = get_latest_tweets(tweetIds)    
        {:reply, tweets, state} 
    end

    #get all subscribers    
    def handle_call({:get_all_subscribers, userId}, _from, state) do
        subscribers_list = GenServer.call(:uss, {:get, :subscribers, userId})
        {:reply, subscribers_list, state}    
    end

    #hashtags-tested
    def handle_call({:hashtag, hashtag}, _from, state) do
        tweetIds = GenServer.call(:ht, {:get, hashtag})
        #list of tweets
        tweets = get_latest_tweets(tweetIds) 
        {:reply, tweets, state}    
    end

    #mentions-tested
    def handle_call({:mention, mention}, _from, state) do
        tweetIds = GenServer.call(:mt, {:get, mention})
        #list of tweets
        tweets = get_latest_tweets(tweetIds) 
        {:reply, tweets, state}    
    end

    #gets all users; for client to select whom to subscribe to: 
    #TODO: test this
    #TODO: this is hacky. change it to database query
    def handle_call(:get_all_users, _from, state) do
        # all_user_ids = GenServer.call(:uss, {:get, :all_users})
        {:reply, 0..(elem(state, 0) - 1), state}    
    end

    #subscribe - tested
    #TODO: change this to call / parallelize table and check again
    def handle_call({:subscribe, userId, subscribeToId}, _from, state) do
        IO.inspect "subscribing #{userId} to #{subscribeToId}"
        res = GenServer.call(:uss, {:update, userId, subscribeToId})
        {:reply, res, state} 
    end

    #tweet-tested
    #TODO: remove timestamp field as tweetid is monotonic?
    def handle_cast({:tweet, userId, tweet}, state) do
        curr_time = System.monotonic_time(:microsecond)
        hashtags = get_hashtags(tweet)
        mentions = get_mentions(tweet)
        #add to userid-tweetids table
        curr_tweet_id_int = elem(state, 1)
        curr_tweet_id = curr_tweet_id_int |> Integer.to_string() |> String.to_atom()
        GenServer.cast(:ut, {:insert_or_update, userId, curr_tweet_id})
        #add to tweetid-tweet-ts table
        GenServer.cast(:tt, {:insert, curr_tweet_id, tweet, curr_time})
        #add to hashtag-tweetid table
        if(hashtags != []) do
            GenServer.cast(:ht, {:insert_or_update, hashtags, curr_tweet_id})    
        end     
        #add to mention-tweedtid table
        if(mentions != []) do
            GenServer.cast(:mt, {:insert_or_update, mentions, curr_tweet_id})    
        end
        {:noreply, {elem(state, 0), curr_tweet_id_int + 1}} 
    end

    #retweet
    def handle_cast({:retweet, userId, tweet}, state) do
        #TODO: logic to a. get feed, b. select 1 at random, c. retweet that on client side
        #Add extra func. if reqd. for Part-II. else merge with tweet
        GenServer.cast(:e, {:tweet, userId, tweet})
        {:noreply, state} 
    end

    
end