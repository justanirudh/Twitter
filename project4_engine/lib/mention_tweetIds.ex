defmodule MentionTweetIds do
    use GenServer

    def init(state) do
        :ets.new(:mt_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert/update
    def handle_cast({:insert_or_update, mentions, curr_tweet_id}, state) do
        #TODO implement this
        Enum.each(mentions, fn(mention) -> 
            if(:ets.lookup(:mt_table, mention) == []) do
                :ets.insert(:mt_table, {mention, [curr_tweet_id]})
            else
                list = :ets.lookup(:mt_table, mention) |> Enum.at(0) |> elem(1)
                :ets.delete(:mt_table, mention)
                :ets.insert(:mt_table, {mention, [curr_tweet_id | list]})
            end
        end)
        {:reply, :ok, state}
        {:reply, :ok, state}
    end

    #get
    def handle_call({:get, mention}, _from, state) do
        list = :ets.lookup(:mt_table, mention) |> Enum.at(0) |> elem(1)     
        {:reply, list, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 
    
end