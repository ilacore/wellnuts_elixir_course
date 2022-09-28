defmodule Mix.Tasks.Holiday do
  use Mix.Task

  def run(_) do
    db = Holiday.init_db()

    case Holiday.is_holiday(db) do
      true -> IO.puts("yes, it is indeed holiday today")
      _ -> IO.puts("it's not holiday today, go back to work")
    end
  end
end
