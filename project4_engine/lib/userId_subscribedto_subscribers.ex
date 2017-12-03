defmodule UserIdSubscribedtoSubscribers do
    use GenServer
    #schema: userid string, subscribed_to_id [], subscribers_ids []

    def init(state) do
        #{:write_concurrency,true}, {:read_concurrency,true}
        :ets.new(:uss_table, [:set, :public, :named_table])
        {:ok, state}
    end

    #insert
    def handle_call({:insert, userId}, _from, state) do
        :ets.insert(:uss_table, {userId, [], []})
        {:reply, :ok, state}
    end

    #get subscribed to
    def handle_call({:get, :subscribed_to, userId}, _from, state) do
        list = :ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1)     
        {:reply, list, state}
    end

    #get subscribers
    # def handle_call({:get, :subscribers, userId}, _from, state) do
    #     list = :ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(2)     
    #     {:reply, list, state}
    # end

    # #get all users
    # def handle_call({:get, :all_users}, _from, state) do
    #     list = :ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1)     
    #     {:reply, list, state}
    # end

    #update
    def handle_call({:update, userId, subscribeToId}, _from, state) do
        if(:ets.lookup(:uss_table, userId) == [] || 
        :ets.lookup(:uss_table, subscribeToId) == [] ||
        Enum.member?(:ets.lookup(:uss_table, userId) |> Enum.at(0) |> elem(1), subscribeToId) == true) do
            #if either of them is not registered OR if they are already in each other's lists
            IO.inspect "either ids not registered or already subscribed to each other"
            #NOP
        else
            IO.inspect "adding ids to each other's lists"
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
        end

        # IO.inspect :ets.lookup(:uss_table, userId)
        # IO.inspect :ets.lookup(:uss_table, subscribeToId)

        {:reply, :ok,  state}
    end

    def handle_info(_msg, state) do #catch unexpected messages
        {:noreply, state}
    end 

end