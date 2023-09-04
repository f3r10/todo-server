defmodule Todo.Database do
  @pool_size 3

  def start_link(db_folder) do
    IO.puts("database init")
    Todo.PoolSupervisor.start_link(db_folder, @pool_size)
  end

  def store(key, data) do
    key
    |> get_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> get_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def get_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end


end
