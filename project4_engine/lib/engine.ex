defmodule Engine do
    use GenServer
    @feed_lim 20
    #state: {curr_user_id, curr_tweet_id}

    #TODO: spawn every task to a new 'Task' to not make engine the bottleneck

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
        |> (Enum.sort_by &(elem(&1, 1))) 
        |> Enum.take(@feed_lim)
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

    #feed
    def handle_call({:feed, userId}, _from, state) do
        #list of userids
        subscribed_to_list = GenServer.call(:uss, {:get, :subscribed_to, userId})
        #list of tweetids
        tweetIds = Enum.flat_map(subscribed_to_list, fn(userId) -> GenServer.call(:ut, {:get, userId}) end)
        #list of tweets
        tweets = get_latest_tweets(tweetIds)    
        {:reply, tweets, state} 
    end

    #hashtags
    def handle_call({:hashtag, hashtag}, _from, state) do
        tweetIds = GenServer.call(:ht, {:get, hashtag})
        #list of tweets
        tweets = get_latest_tweets(tweetIds) 
        {:reply, tweets, state}    
    end

    #mentions
    def handle_call({:mention, mention}, _from, state) do
        tweetIds = GenServer.call(:mt, {:get, mention})
        #list of tweets
        tweets = get_latest_tweets(tweetIds) 
        {:reply, tweets, state}    
    end

    #tweet
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

    #subscribe - tested
    def handle_cast({:subscribe, userId, subscribeToId}, state) do
        IO.inspect "subscribing #{userId} to #{subscribeToId}"
        GenServer.cast(:uss, {:update, userId, subscribeToId})
        {:noreply, state} 
    end

    #retweet
    def handle_cast({:retweet, userId, tweet}, state) do
        #TODO: logic to a. get feed, b. select 1 at random, c. retweet that on client side
        #Add extra func. if reqd. for Part-II. else merge with tweet
        GenServer.cast(:e, {:tweet, userId, tweet})
        {:noreply, state} 
    end

    
end