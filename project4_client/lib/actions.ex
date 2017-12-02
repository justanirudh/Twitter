defmodule Actions do

    def subscribe_to(userId, subscribeToId, engine_pid) do
        GenServer.call(engine_pid, {:subscribe, userId, subscribeToId})   
    end

    def get_sample_hashtags(engine_pid) do
        GenServer.call(engine_pid, {:hashtag, :getkeys})
    end

    def get_tweets_with_hashtag(hashtag, engine_pid) do
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


end