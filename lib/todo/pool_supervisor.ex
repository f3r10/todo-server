defmodule Todo.PoolSupervisor do
  use Supervisor

  def start_link(db_folder, pool_size) do
    Supervisor.start_link(__MODULE__, {db_folder, pool_size})
  end

  def init({db_folder, pool_size}) do
    processes =
      for worker_id <- 1..pool_size do
        %{
          id: {:database_worker, worker_id},
          start: {Todo.DatabaseWorker, :start_link, [db_folder, worker_id]},
          type: :worker
        }
      end
    Supervisor.init(processes, strategy: :one_for_one)
  end
end
