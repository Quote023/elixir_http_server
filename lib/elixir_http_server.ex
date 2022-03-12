alias ElixirHttpServer.{Server}

defmodule ElixirHttpServer do
  use Application

  def start(_type, _args) do
    Server.run()

    {:ok, self()}
  end
end
