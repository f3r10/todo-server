defmodule Todo.Supervisor do
  use Supervisor

  def init(_) do
    processes = [
      %{
        id: Todo.ProcessRegistry,
        start: {Todo.ProcessRegistry, :start_link, []},
        # default type
        type: :worker
      },
      %{
        id: Todo.Database,
        start: {Todo.Database, :start_link, ["./persist"]},
        type: :supervisor
      },
      %{
        id: Todo.ServerSupervisor,
        start: {Todo.ServerSupervisor, :start_link, []},
        # default type
        type: :supervisor
      },
      %{
        id: Todo.Cache,
        start: {Todo.Cache, :start_link, []},
        # default type
        type: :worker
      },
    ]

    Supervisor.init(processes, strategy: :one_for_one)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end
end
