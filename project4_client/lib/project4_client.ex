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
    {:ok, _} = Node.start(String.to_atom("client@127.0.0.1")) #converts current node to distributed node
    app_name = :p4
    Application.get_env(app_name, :cookie) |> Node.set_cookie #gets common cookie and sets the master's with it
    #connect to master
    _ = Node.connect(String.to_atom("engine@127.0.0.1")) #connect to master
    :global.sync #sync global registry to let slave know of master being named :master
    master_node_pid = :global.whereis_name(:master)
    send master_node_pid, {:from_client, "hello from client"}

    
  end
end
