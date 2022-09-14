defmodule JokeTest do
  use ExUnit.Case
  doctest Joke

  test "greets the world" do
    assert Joke.hello() == :world
  end
end
