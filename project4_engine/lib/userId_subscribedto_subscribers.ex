defmodule UserIdSubscribedtoSubscribers do
    use GenServer
    #state: curr_user_id

    def init(state) do
        :ets.new(:uss_table, [:set, :public, :named_table])
        {:ok, state}
    end

    def handle_call({:insert, userId}, _from, state) do
        #TODO implement this
        {:reply, :ok, state + 1}
    end

    def handle_call({:get, :subscribed_to, userId}, _from, state) do
        #TODO implement this
        {:reply, :ok, state}
    end

    def handle_cast({:update, userId, subscribeToId}, state) do
        #TODO implement this
        {:noreply, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 

end