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
    user_id1 = GenServer.call(master_node_pid, :register)
    IO.inspect user_id1
    
    user_id2 = GenServer.call(master_node_pid, :register)
    IO.inspect user_id2

    user_id3 = GenServer.call(master_node_pid, :register)
    IO.inspect user_id3

    #subscribe
    GenServer.cast(master_node_pid, {:subscribe, user_id1, user_id2})
    GenServer.cast(master_node_pid, {:subscribe, user_id1, user_id3})
    
    t1 = "foo"
    t2 = "bar"
    t3 = "baz"
    t4 = "foo2"
    t5 = "bar2"
    t6 = "baz2"

    GenServer.cast(master_node_pid, {:tweet, user_id2,t1})
    GenServer.cast(master_node_pid, {:tweet, user_id2,t2})
    GenServer.cast(master_node_pid, {:tweet, user_id3,t3})
    GenServer.cast(master_node_pid, {:tweet, user_id3,t4})
    GenServer.cast(master_node_pid, {:tweet, user_id2,t5})
    GenServer.cast(master_node_pid, {:tweet, user_id3,t6})

    feed = GenServer.call(master_node_pid, {:feed, user_id1})
    IO.inspect feed # t6, t3, t5: baz2, baz, bar2

    # #get hashtags
    # list = GenServer.call(master_node_pid, {:mention, "@hey"})
    # IO.inspect list #should be last and second last


    #subscribe
    # GenServer.cast(master_node_pid, {:subscribe, :'1', :'0'})

  end
end
