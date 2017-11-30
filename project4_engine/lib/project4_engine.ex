defmodule TwitterEngine do
  @moduledoc """
  Documentation for TwitterEngine.
  """
  
  def loop do
    :timer.sleep(1000000000)
    loop
  end

  def main(args) do
    IO.inspect "hello"

    #starter process
    self() |> Process.register(:master)

    #5 tables
    elem(GenServer.start_link(UserIdSubscribersSubscribedto, 0), 1) |> Process.register(:uss)
    elem(GenServer.start_link(UserIdTweetIds, []), 1) |> Process.register(:ut)
    elem(GenServer.start_link(HashtagTweetIds, []), 1) |> Process.register(:ht)
    elem(GenServer.start_link(MentionTweetIds, []), 1) |> Process.register(:mt)
    elem(GenServer.start_link(TweetIdTweet, []), 1) |> Process.register(:tt)

    #engine
    elem(GenServer.start_link(Engine, []), 1) |> Process.register(:e)

    #loop infinitely
    loop()


  end
end
