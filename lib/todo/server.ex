defmodule Todo.Server do
  use GenServer

  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  def start_link(name) do
    GenServer.start_link(Todo.Server, name)
  end
  
  def add_entry(pid, %Todo.Entry{} = new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_call({:entries, date}, _ ,  {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end
  
end
