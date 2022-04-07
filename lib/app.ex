alias ElixirHttpServer.{Server}

defmodule ElixirHttpServer do
  use Application

  def start(_type, _args) do

    MovieDB.makeDb()
|> MovieDB.findInDb("star wars")
|> IO.inspect()
   # Server.run()

    {:ok, self()}
  end
end
