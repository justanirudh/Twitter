defmodule MentionTweetIds do
    use GenServer

    def init(state) do
        :ets.new(:mt_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert/update
    def handle_cast({:insert_or_update, mentions, curr_tweet_id}, state) do
        #TODO implement this
        {:reply, :ok, state}
    end

    #get
    def handle_call({:get, mention}, _from, state) do
        #TODO implement this
        {:reply, :ok, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 
    
end