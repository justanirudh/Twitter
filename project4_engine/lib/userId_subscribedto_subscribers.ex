defmodule UserIdSubscribedtoSubscribers do
    use GenServer
    #schema: userid string, subscribed_to_id [], subscribers_ids []

    def init(state) do
        :ets.new(:uss_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert
    def handle_call({:insert, userId}, _from, state) do
        :ets.insert(:uss_table, {userId, [], []})
        {:reply, :ok, state}
    end

    #get
    def handle_call({:get, :subscribed_to, userId}, _from, state) do
        list = :ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1)     
        {:reply, list, state}
    end

    #update
    def handle_cast({:update, userId, subscribeToId}, state) do

        #add to subscribed_to list of userid
        #save states
        user_id_row = :ets.lookup(:uss_table, userId) |> Enum.at(0)
        subscribed_to_list = user_id_row |> elem(1)
        subscribers_list = user_id_row |> elem(2)
        #delete row
        :ets.delete(:uss_table, userId)
        #add new row
        :ets.insert(:uss_table, {userId, [subscribeToId | subscribed_to_list], subscribers_list})

        #add to subscribers list of subscribeToId
        user_id_row = :ets.lookup(:uss_table, subscribeToId) |> Enum.at(0)
        subscribed_to_list = user_id_row |> elem(1)
        subscribers_list = user_id_row |> elem(2)
        #delete row
        :ets.delete(:uss_table, subscribeToId)
        #add new row
        :ets.insert(:uss_table, {subscribeToId, subscribed_to_list, [ userId | subscribers_list]})

        {:noreply, state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 

end