defmodule TwitterClient do
  @moduledoc """
  Documentation for TwitterClient.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TwitterClient.hello
      :world

  """
  def hello do
    :world
  end

  def main(args) do
    #epmd -daemon
    {:ok, _} = Node.start(String.to_atom("client@127.0.0.1")) 
    Application.get_env(:p4, :cookie) |> Node.set_cookie 
    _ = Node.connect(String.to_atom("engine@127.0.0.1")) #connect to master
    :global.sync #sync global registry to let slave know of master being named :master
    master_node_pid = :global.whereis_name(:engine)
    
    #register
    user_id = GenServer.call(master_node_pid, :register)
    IO.inspect user_id

    #tweet
    tweet = "my first tweet #hey @mom"
    GenServer.cast(master_node_pid, {:tweet, user_id,tweet})
    tweet = "my second tweet #again_hey @dad"
    GenServer.cast(master_node_pid, {:tweet, user_id,tweet})
    


    #subscribe
    # GenServer.cast(master_node_pid, {:subscribe, :'1', :'0'})

  end
end
