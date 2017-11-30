defmodule HashtagTweetIds do
    use GenServer
    #schema: hashtag string, tweetids [:atom]

    def init(state) do
        :ets.new(:ht_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert/update
    def handle_cast({:insert_or_update, hashtags, curr_tweet_id}, state) do
        Enum.each(hashtags, fn(hashtag) -> 
            if(:ets.lookup(:ht_table, hashtag) == []) do
                :ets.insert(:ht_table, {hashtag, [curr_tweet_id]})
            else
                list = :ets.lookup(:ht_table, hashtag) |> Enum.at(0) |> elem(1)
                :ets.delete(:ht_table, hashtag)
                :ets.insert(:ht_table, {hashtag, [curr_tweet_id | list]})
            end
        end)
        Enum.each(hashtags, fn(htag) -> 
            IO.inspect "hashtag-tweetid table entry:"  
            IO.inspect :ets.lookup(:ht_table, htag)  
        end)
        {:noreply, state}
    end

    #get
    def handle_call({:get, hashtag}, _from, state) do
        list = :ets.lookup(:ht_table, hashtag) |> Enum.at(0) |> elem(1)     
        {:reply, list, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 
    
end