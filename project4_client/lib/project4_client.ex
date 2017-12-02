defmodule TwitterClient do
  @moduledoc """
  Documentation for TwitterClient.
  """

  def print_tweet_rate() do
    prev = System.monotonic_time(:microsecond) #start timer
    receive do
      {:print, num_tweets} ->
        next = System.monotonic_time(:microsecond)
        time_taken = next - prev
        IO.inspect "num_tweets: #{num_tweets}"
        IO.inspect "time taken: #{time_taken}"
        rate = (num_tweets/time_taken) * 1000000
        IO.inspect "tweet-rate = #{rate} per second"
    end
      print_tweet_rate()
  end

  def main(args) do

    num_users = 1000 #TODO: change to 500k
    zipf_factor = 100/1000 #(factor / fraction of a millisecond wait time) 
    print_every_factor = 5
    hashtags_size = 1000
    mentions_size = 1000
    tweets_size = 8000
    
    #prepare hashtags, mentions, tweets
    hashtags = Utils.get_hashtags(1, hashtags_size, [])
    mentions = Utils.get_mentions(hashtags_size + 1, hashtags_size + mentions_size, [])
    # tweets = Utils.get_tweets(hashtags_size + mentions_size + 1,hashtags_size + mentions_size + tweets_size, hashtags, hashtags_size,mentions, mentions_size,[], true, false, 0, 0)

    tweets = Utils.get_tweets(1,100,hashtags, hashtags_size,mentions, mentions_size,[], true, false, 0, 0)
    IO.inspect hashtags
    IO.inspect mentions
    IO.inspect tweets

    # #epmd -daemon
    {:ok, _} = Node.start(String.to_atom("client@127.0.0.1")) 
    Application.get_env(:p4, :cookie) |> Node.set_cookie 
    _ = Node.connect(String.to_atom("engine@127.0.0.1")) #connect to master
    :global.sync #sync global registry to let slave know of master being named :master
    engine_pid = :global.whereis_name(:engine)

    #register client-master
    client_master_pid = self()
    :ok = GenServer.call(engine_pid, {:register_client_master, client_master_pid, num_users * print_every_factor})

    #start users
    state = %{:hashtags => hashtags,
    :mentions => mentions,
    :num_users => num_users, 
    :zipf_factor => zipf_factor, 
    :engine_pid => engine_pid}

    client_pids = 0..num_users-1 |> Enum.map(fn(rank) -> GenServer.start_link(Client, Map.put(state, :rank, rank) ) |> elem(1)  end)

    #register all users
    Enum.each(client_pids, fn(pid) -> GenServer.call(pid, :register) end )

    IO.inspect "Registered all users"
    
    #make clients subscribe by zipf (power law)
    # Enum.each(client_pids, fn(pid) -> GenServer.call(pid, :subscribe) end )

    # IO.inspect "Created zipf distribution of subscription model"

    #populate subscribers size for each client to simulate zipf distribution for tweets
    # Enum.each(client_pids, fn(pid) -> GenServer.call(pid, :get_subscribers_size) end )

    IO.inspect "Users started tweeting"
    
    #make clients tweet by zipf law (80-20)
    0..num_users-1 |> Enum.each(fn(idx) -> GenServer.cast(Enum.at(client_pids, idx), {:tweet, tweets, idx}) end )

    IO.inspect "All users started tweeting"

    print_tweet_rate()

  end
end
