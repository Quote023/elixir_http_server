defmodule ElixirHttpServerTest do
  use ExUnit.Case
  doctest ElixirHttpServer

  test "greets the world" do
    assert ElixirHttpServer.hello() == :world
  end
end
