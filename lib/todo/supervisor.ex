defmodule Todo.Supervisor do
  use Supervisor

  def init(_) do
    processes = [
      %{
        id: Todo.Cache,
        start: {Todo.Cache, :start_link, []},
        # default type
        type: :worker
      }
    ]

    Supervisor.init(processes, strategy: :one_for_one)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end
end
