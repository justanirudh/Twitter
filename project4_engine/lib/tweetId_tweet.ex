defmodule TweetIdTweet do
    use GenServer
    #schema tweetids atom, tweet string, timestamp number

    def init(state) do
        :ets.new(:tt_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert
    def handle_cast({:insert, curr_tweet_id, tweet, curr_time}, state) do
        :ets.insert(:tt_table, {curr_tweet_id, tweet, curr_time})
        IO.inspect "tweetid-tweet-ts table entry:"
        IO.inspect :ets.lookup(:tt_table, curr_tweet_id)
        {:noreply, state}
    end

    #get
    def handle_call({:get, tweetId}, _from, state) do
        {_, tweet, ts} = :ets.lookup(:tt_table, tweetId) |> Enum.at(0)  
        {:reply, {tweet, ts}, state}
    end

    #catch unexpected messages
    def handle_info(_msg, state) do 
        {:noreply, state}
    end 
end