defmodule MovieDB do
  @dbfolder Path.join(:code.priv_dir(:elixir_http_server), "db/movies.txt")

  def makeDb() do
    {:ok, file} = File.read(@dbfolder)

    file
    |> String.split("\r\n\r\n", trim: true)
    |> Enum.map(fn mov -> String.split(mov, "\r\n", trim: true) end)
    |> Enum.map(fn mov ->
        Enum.map( mov, (fn mov2 ->
          String.split(mov2, " ", trim: true, parts: 2)
    end))
    |> Map.new(
        fn x ->
          {Enum.at(x,0), Enum.at(x,1)}
  end)
end)


  end

  def findInDb(base, name) do

      Enum.find(base, fn x -> String.contains?(x["NOME"], String.upcase(name)) end)

  end
end
