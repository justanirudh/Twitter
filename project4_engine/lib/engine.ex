defmodule Engine do
    use GenServer
    @feed_lim 20

    #TODO: spawn every task to a new 'Task' to not make engine the bottleneck

    defp get_hashtags(tweet) do
        #TODO implement this
    end

    defp get_mentions(tweet) do
        #TODO implement this
    end

    defp get_latest_tweets(tweets_ts) do
        #TODO implement this
        #arrange in decreasing order of timestamps
        #get first #feed_lin tweets
    end

    #register
    def handle_call({:register, userId}, _from, state) do
        :ok = GenServer.call(:uss, {:insert, userId})
        {:reply, :ok, state} 
    end

    #feed
    def handle_call({:feed, userId}, _from, state) do
        #list of userids
        subscribed_to_list = GenServer.call(:uss, {:get, :subscribed_to, userId})
        #list of tweetids
        tweetids = Enum.flat_map(subscribed_to_list, fn(userId) -> GenServer.call(:ut, {:get, userId}) end)
        #list of (tweets,timestamps)
        tweets_ts = Enum.map(tweetids, fn(tweetId) -> GenServer.call(:tt, {:get, tweetId})  end)
        #list of tweets
        tweets = get_latest_tweets(tweets_ts)    
        #TODO finish this
        {:reply, tweets, state} 
    end

    #tweet
    def handle_cast({:tweet, userId, tweet}, state) do
        curr_time = System.monotonic_time(:microsecond)
        hashtags = get_hashtags(tweet)
        mentions = get_mentions(tweet)
        #add to ut table
        tweetId = GenServer.call(:ut, {:insert, userId})
        #add to tweet table
        GenServer.cast(:tt, {:insert, tweetId, tweet, curr_time})
        #add to hashtag table
        GenServer.cast(:ht, {:insert, hashtags, tweetId})
        #add to mentions table
        GenServer.cast(:mt, {:insert, mentions, tweetId})
        
        {:noreply, state} 
    end

    #subscribe
    def handle_cast({:subscribe, userId, subscribeToId}, state) do
        GenServer.cast(:uss, {:update, userId, subscribeToId})
        {:noreply, state} 
    end



    #retweet
    def handle_cast({:retweet, userId, tweet}, state) do
        #TODO: use feed to get last 20
        GenServer.cast(:ut, {:uit, userId, tweet})
        {:noreply, state} 
    end
    
end