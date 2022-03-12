defmodule ElixirHttpServer.Server do
  @options [
    :binary,
    active: false,
    packet: 0
  ]
  def run(port \\ 8000) do
    IO.puts(IO.ANSI.clear() <> IO.ANSI.home())
    IO.puts("[SERVER] iniciando servidor na porta #{port}")

    case :gen_tcp.listen(port, @options) do
      {:ok, socket} -> handle({:accept, socket})
      {:error, reason} -> handle({:error, reason}, "falha ao inicializar o servidor")
    end
  end

  def handle({:accept, _socket}) do
    IO.puts("ACEITAR")
    :ok
  end

  def handle({:data, _socket}) do
    IO.puts("DATA")
    :ok
  end

  def handle({:closed, _}) do
    :ok
  end

  def handle({:error, reason}, message \\ "erro inesperado") do
    IO.puts(
      :stderr,
      IO.ANSI.format([
        :red_background,
        :black,
        "[SERVER] #{message}. ERRCODE: #{reason}"
      ])
    )

    :error
  end
end
