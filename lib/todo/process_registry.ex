defmodule Todo.ProcessRegistry do
  import Kernel, except: [send: 2]
  use GenServer

  def init(_) do
    {:ok, Map.new()}
  end

  def start_link do
    IO.puts("Starting process registry.")
    GenServer.start_link(__MODULE__, nil, name: :todo_process_registry)
  end

  def register_name(worker, pid) do
    GenServer.call(:todo_process_registry, {:register_name, worker, pid})
  end

  def whereis_name(worker) do
    GenServer.call(:todo_process_registry, {:whereis_name, worker})
  end

  def unregister_name(worker) do
    GenServer.call(:todo_process_registry, {:unregister_name, worker})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid -> 
        Kernel.send(pid, message)
        pid
    end
    
  end

  def handle_call({:register_name, key, pid}, _, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(process_registry, key, pid)}

      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:whereis_name, key}, _, process_registry) do
    {:reply, Map.get(process_registry, key, :undefined), process_registry}
  end

  def handle_call({:unregister_name, key}, _, process_registry) do
    new_process_registry = deregister_pid(process_registry, key)
    {:reply, new_process_registry, new_process_registry}
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    {:noreply, deregister_pid(process_registry, pid)}
  end

  defp deregister_pid(process_registry, pid) do
    process_registry
    |> Enum.filter(fn({_registered_alias, registered_process}) -> registered_process != pid end)
    |> Enum.into(%{})
  end
end
