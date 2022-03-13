defmodule ElixirHttpServer.Server do
  @type socket :: :gen_tcp.socket()
  @options [
    :binary,
    reuseaddr: true,
    active: false,
    packet: 0
  ]

  @spec run(integer()) :: :error | :ok
  def run(port \\ 8000) do
    IO.puts(IO.ANSI.clear() <> IO.ANSI.home())
    IO.puts("[SERVER] iniciando servidor na porta #{port}")
    handle({:listen, port})
  end

  @spec handle(
          {:listen, integer()}
          | {:accept, socket}
          | {:close, conn_params | data_params}
          | {:receive, socket}
          | {:error, {error_code, error_message}}
          | {:data, data_params}
        ) :: :error | :ok
        when error_message: String.t(),
             error_code: atom(),
             conn_params: %{client: socket},
             data_params: %{client: socket, data: binary()}

  def handle({:listen, port}) do
    case :gen_tcp.listen(port, @options) do
      {:ok, socket} -> handle({:accept, socket})
      {:error, reason} -> handle({:error, {reason, "falha ao inicializar o servidor"}})
    end
  end

  def handle({:accept, listening_socket}) do
    IO.puts("aceitando conexão...")

    case :gen_tcp.accept(listening_socket) do
      {:ok, socket} ->
        handle({:receive, %{client: socket}})
        # Reinicia recursivamente pra atender a proxima requisição
        handle({:accept, listening_socket})

      {:error, reason} ->
        handle({:error, {reason, "falha ao aceita socket"}})
    end
  end

  def handle({:receive, conn}) do
    IO.puts("recebendo dados...")

    case :gen_tcp.recv(conn.client, 0) do
      {:ok, data} -> handle({:data, Map.put(conn, :data, data)})
      {:error, reason} -> handle({:error, {reason, "falha ao receber dados"}})
    end
  end

  def handle({:data, conn}) do
    data = conn.data
    IO.puts("Dados Recebidos:")
    IO.puts(to_string(data) <> "\r\n")

    message = ":^)\r\n"

    payload =
      "HTTP/1.0 200 OK\r\n" <>
        "Content-Type: text/html\r\n" <>
        "Content-Length: #{byte_size(message)}" <>
        "\r\n\r\n" <>
        message

    case :gen_tcp.send(conn.client, payload) do
      :ok -> handle({:close, conn})
      {:error, reason} -> handle({:error, {reason, "falha ao responder requisição"}})
    end
  end

  def handle({:close, conn}) do
    try do
      :ok = :gen_tcp.shutdown(conn.client, :read_write)
      IO.puts("Conexão fechada!")
    rescue
      x -> handle({:error, {x.message, "falha ao fechar conexão"}})
    end
  end

  def handle({:error, {reason, message}}) do
    message = IO.ANSI.format([:red_background, :black, "[SERVER] #{message}. ERRCODE: #{reason}"])
    IO.puts(:stderr, message)
    :error
  end
end
