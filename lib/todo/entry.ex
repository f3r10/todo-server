defmodule Todo.Entry do
  defstruct date: {}, title: String

  def new(date, title), do: %Todo.Entry{date: date, title: title}
end

