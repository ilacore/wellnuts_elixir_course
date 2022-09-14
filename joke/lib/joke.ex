defmodule Joke do
  @moduledoc """
  Documentation for Joke.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Joke.hello()
      :world

  """
  defstruct [:setup, :punchline]

  def get_joke do
    HTTPoison.start()

    joke =
      HTTPoison.get!("https://official-joke-api.appspot.com/random_joke").body
      |> Jason.decode!()

    %Joke{setup: joke["setup"], punchline: joke["punchline"]}
  end

  def print_joke do
    joke = get_joke()
    IO.puts("- #{joke.setup} \n- #{joke.punchline}")
  end

  def hello do
    :world
  end
end
