defmodule Todo.List do
  defstruct auto_id: 1, entries: Map.new()

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      fn entry, todo_list_acc ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  @spec add_entry(%Todo.List{}, %Todo.Entry{}) :: %Todo.List{}
  def add_entry(
        %Todo.List{entries: entries, auto_id: auto_id} = todo_list,
        %Todo.Entry{} = entry
      ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)
    %Todo.List{todo_list | auto_id: auto_id + 1, entries: new_entries}
  end

  def entries(
        %Todo.List{entries: entries},
        date
      ) do
    entries
    |> Stream.filter(fn {_, entry} ->
      entry.date == date
    end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  @spec update_entry(
          %Todo.List{},
          integer,
          (existing_value :: %Todo.List{} -> new_value :: %Todo.List{})
        ) :: %Todo.List{}
  def update_entry(
        %Todo.List{entries: entries} = todo_list,
        entry_id,
        updated_fun
      ) do
    case entries[entry_id] do
      nil ->
        todo_list

      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updated_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  @spec delete_entry(%Todo.List{}, integer) :: %Todo.List{}
  def delete_entry(%Todo.List{entries: entries} = todo_list, entry_id) do
    new_entries = Map.delete(entries, entry_id)
    %Todo.List{todo_list | entries: new_entries}
  end
end
