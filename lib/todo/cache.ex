defmodule Todo.Cache do
  use GenServer

  def init(_) do
    {:ok, Map.new()}
  end

  def start_link do
    IO.puts("Starting to-do cache.")
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(todo_list_name) do
    case Todo.Server.whereis(todo_list_name) do
      pid when is_pid(pid) -> pid
      :undefined -> 
        GenServer.call(:todo_cache, {:server_process, todo_list_name})
    end
  end

  def handle_call({:server_process, todo_list_name}, _, _) do
    case Todo.Server.whereis(todo_list_name) do
      pid when is_pid(pid) ->
        {:reply, pid, %{}}

      :undefined ->
        case Todo.ServerSupervisor.start_child(todo_list_name) do
          {:ok, pid} -> {:reply, pid, %{}}
          {:ok, pid, _} -> {:reply, pid, %{}}
          {:error, {:already_started, pid}} -> {:reply, pid, %{}}
        end
    end
  end
end
