defmodule Movie do
    defstruct [:NOME, :ANO, :FAIXAETARIA, :GENERO,:DIRETOR]
end

defmodule MovieDB do

  def makeDb() do
    path = Path.join(:code.priv_dir(:elixir_http_server), "db/movies.txt")
    {:ok, file} = File.read(path)

    file
    |> String.split("\n\n", [trim: true])
    |> Enum.map(fn mov -> String.split(mov,"\n", [trim: true]) end)
    |> Enum.reduce([],fn (movie,acc) ->
      movie
      |> Enum.map("")
    end)

  end

end
