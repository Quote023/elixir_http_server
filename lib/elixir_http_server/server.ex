alias ElixirHttpServer.{HttpResponse}

defmodule ElixirHttpServer.Server do
  @type socket :: :gen_tcp.socket()
  @options [
    :binary,
    reuseaddr: true,
    active: false,
    packet: 0
  ]

  def run(port \\ 8000) do
    IO.puts(IO.ANSI.clear() <> IO.ANSI.home())
    IO.puts("[SERVER] iniciando servidor na porta #{port}")
    IO.puts("[DB] iniciando banco de dados")
    find_movie = fn name -> MovieDB.makeDb() |> MovieDB.findInDb(name) end

    handle_listen(port, %{
      common: %{},
      system: %{find_movie: find_movie, movies: MovieDB.makeDb()}
    })
  end

  def handle_listen(port, initial_state \\ %{common: %{}}) do
    case :gen_tcp.listen(port, @options) do
      {:ok, socket} -> handle_accept(socket, port, initial_state)
      {:error, reason} -> handle_error(reason, "falha ao inicializar o servidor")
    end
  end

  def handle_accept(listening_socket, port, state) do
    IO.puts("aceitando conexão...")

    case :gen_tcp.accept(listening_socket) do
      {:ok, socket} ->
        state =
          case handle_receive(socket, state) do
            {:update_state, new_state} -> new_state
            _ -> state
          end

        # Reinicia recursivamente pra atender a proxima requisição
        handle_accept(listening_socket, port, state)

      {:error, reason} ->
        handle_error(reason, "falha ao aceita socket")
    end
  end

  def handle_receive(client, state) do
    IO.puts("recebendo dados...")

    case :gen_tcp.recv(client, 0, 5000) do
      {:ok, data} -> handle_data(client, data, state)
      {:error, reason} -> handle_error(reason, "falha ao receber dados")
    end
  end

  def handle_data(client, request_str, state) do
    IO.puts("Dados Recebidos:")
    IO.puts(request_str <> "\r\n")

    {response_data, new_state} =
      request_str
      |> RequestParser.parse()
      |> Router.handle_route(state)

    response = HttpResponse.new(response_data, 200, %{"Set-Cookie" => "sessionId=38afes7a8"})

    case :gen_tcp.send(client, response) do
      :ok ->
        case handle_close(client) do
          :ok -> {:update_state, new_state}
          :error -> :error
        end

      {:error, reason} ->
        handle_error(reason, "falha ao responder requisição")
    end
  end

  def handle_close(client) do
    try do
      :ok = :gen_tcp.shutdown(client, :read_write)
      IO.puts("Conexão fechada!")
    rescue
      x -> handle_error(x.message, "falha ao fechar conexão")
    end
  end

  def handle_error(reason, message \\ "erro_inesperado") do
    message = IO.ANSI.format([:red_background, :black, "[SERVER] #{message}. ERRCODE: #{reason}"])
    IO.puts(:stderr, message)
    :error
  end
end
