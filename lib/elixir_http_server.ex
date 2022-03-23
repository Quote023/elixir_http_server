alias ElixirHttpServer.{Server}

defmodule ElixirHttpServer do
  use Application

  def start(_type, _args) do
    IO.inspect(MovieDB.makeDb())

    # Server.run()

    {:ok, self()}
  end
end
