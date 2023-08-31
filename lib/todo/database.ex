defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    IO.puts("database init")
    GenServer.start(__MODULE__, db_folder, name: :database_server)
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
    GenServer.call(:database_server, {:get_worker, key})
  end

  def init(db_folder) do
    workers = Enum.reduce(1..3, Map.new(), fn index, acc ->
      {:ok, worker_pid} = Todo.DatabaseWorker.start(db_folder)
      Map.put(acc, index - 1, worker_pid)
    end)

    {:ok, workers}
  end

  def handle_call({:get_worker, key}, _, workers) do
    IO.puts("get_worker")
    worker_key = :erlang.phash2(key, 3)
    {:ok, worker_pid} = Map.fetch(workers, worker_key)
    {:reply, worker_pid, workers}
  end

end
