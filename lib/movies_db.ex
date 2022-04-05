defmodule Movie do
  defstruct [:NOME, :ANO, :FAIXAETARIA, :GENERO, :DIRETOR]
end

defmodule MovieDB do
  @dbfolder Path.join(:code.priv_dir(:elixir_http_server), "db/movies.txt")

  def makeDb() do
    {:ok, file} = File.read(@dbfolder)

    file
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn mov -> String.split(mov, "\n", trim: true) end)
    |> Enum.reduce([], fn movie, _acc ->
      movie
      |> Enum.map("")
    end)
  end
end