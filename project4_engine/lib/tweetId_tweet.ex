defmodule TweetIdTweet do
    use GenServer

    def init(state) do
        :ets.new(:tt_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert/update
    def handle_cast({:insert, curr_tweet_id, tweet, curr_time}, state) do
        #TODO implement this
        {:reply, :ok, state}
    end

    #get
    def handle_call({:get, tweetId}, _from, state) do
        #TODO implement this
        {:reply, :ok, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 
end