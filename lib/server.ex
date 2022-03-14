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
    handle_listen(port)
  end

  def handle_listen(port) do
    case :gen_tcp.listen(port, @options) do
      {:ok, socket} -> handle_accept(socket)
      {:error, reason} -> handle_error(reason, "falha ao inicializar o servidor")
    end
  end

  def handle_accept(listening_socket) do
    IO.puts("aceitando conexão...")

    case :gen_tcp.accept(listening_socket) do
      {:ok, socket} ->
        handle_receive(socket)
        # Reinicia recursivamente pra atender a proxima requisição
        handle_accept(listening_socket)

      {:error, reason} ->
        handle_error(reason, "falha ao aceita socket")
    end
  end

  def handle_receive(client) do
    IO.puts("recebendo dados...")

    case :gen_tcp.recv(client, 0) do
      {:ok, data} -> handle_data(client, data)
      {:error, reason} -> handle_error(reason, "falha ao receber dados")
    end
  end

  def handle_data(client, data) do
    IO.puts("Dados Recebidos:")
    IO.puts(to_string(data) <> "\r\n")

    message = "<div style=\"font-size: 30rem\">:^)</div>\r\n"

    payload =
      "HTTP/1.0 200 OK\r\n" <>
        "Content-Type: text/html\r\n" <>
        "Content-Length: #{byte_size(message)}" <>
        "\r\n\r\n" <>
        message

    case :gen_tcp.send(client, payload) do
      :ok -> handle_close(client)
      {:error, reason} -> handle_error(reason, "falha ao responder requisição")
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
