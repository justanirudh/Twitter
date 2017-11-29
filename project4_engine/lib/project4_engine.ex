defmodule TwitterEngine do
  @moduledoc """
  Documentation for TwitterEngine.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TwitterEngine.hello
      :world

  """
  def hello do
    :world
  end

  def main(args) do
    IO.inspect "hello"

    self() |> Process.register(:master)

    elem(GenServer.start_link(UserIdSubscribersSubscribedto, []), 1) |> Process.register(:uss)
    elem(GenServer.start_link(UserIdTweetIds, []), 1) |> Process.register(:ut)
    elem(GenServer.start_link(HashtagTweetIds, []), 1) |> Process.register(:ht)
    elem(GenServer.start_link(MentionTweetIds, []), 1) |> Process.register(:mt)
    elem(GenServer.start_link(TweetIdTweet, []), 1) |> Process.register(:tt)



  end
end
