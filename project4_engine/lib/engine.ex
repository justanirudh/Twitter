defmodule Engine do
    use GenServer
    @feed_lim 20

    #register
    def handle_call({:register, userId}, _from, state) do
        :ok = GenServer.call(:uss, {:ui, userId})
        {:reply, :ok, state} 
    end

    #tweet
    def handle_cast({:tweet, userId, tweet}, state) do
        GenServer.cast(:ut, {:uit, userId, tweet})
        {:noreply, state} 
    end

    #subscribe
    def handle_cast({:subscribe, userId, subscribeToId}, state) do
        GenServer.cast(:uss, {:uisi, userId, subscribeToId})
        {:noreply, state} 
    end

    #retweet
    def handle_cast({:retweet, userId, tweet}, state) do
        GenServer.cast(:ut, {:uit, userId, tweet})
        {:noreply, state} 
    end
    
end