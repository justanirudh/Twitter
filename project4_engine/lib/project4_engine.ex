defmodule TwitterEngine do
  @moduledoc """
  Documentation for TwitterEngine.
  """
  
  def loop do
    :timer.sleep(1000000000)
    loop
  end

  def main(args) do

    #starter process
    self() |> Process.register(:master)

    #5 tables
    elem(GenServer.start_link(UserIdSubscribedtoSubscribers, []), 1) |> Process.register(:uss)
    elem(GenServer.start_link(UserIdTweetIds, []), 1) |> Process.register(:ut)
    elem(GenServer.start_link(HashtagTweetIds, []), 1) |> Process.register(:ht)
    elem(GenServer.start_link(MentionTweetIds, []), 1) |> Process.register(:mt)
    elem(GenServer.start_link(TweetIdTweet, []), 1) |> Process.register(:tt)

    #engine
    elem(GenServer.start_link(Engine, {0,0}), 1) |> Process.register(:e)

    #TODO: remove this: to check if cross node comm works
    #epmd -daemon
    master = self()
    {:ok, _} = Node.start(String.to_atom("engine@127.0.0.1"))
    app_name = :p4
    Application.get_env(app_name, :cookie) |> Node.set_cookie #gets common cookie and sets the master's with it
    :global.register_name(:master, master) #registers it for all connected nodes

  receive do
      {:from_client, msg} -> IO.inspect msg
  end

    #loop infinitely
    loop()


  end
end
