defmodule RequestParser do
  def parse(request) do
    # separar header do body
    req = request |> String.split("\r\n\r\n", trim: true)
    body = Enum.at(req, 1, "")

    Enum.at(req, 0)
    |> parse_header()
    |> Map.new()
    |> Map.put(:raw, request)
    |> Map.put(:body, body)
  end

  def parse_header(header_str) do
    header_str
    |> String.split("\r\n", trim: true)
    |> Enum.flat_map(fn x ->
      case String.split(x, ":", parts: 2) do
        [first_line] ->
          [method, endpoint, protocol] = String.split(first_line, " ")
          path = endpoint |> String.split("?") |> Enum.at(0)

          [
            {:method, method},
            {:endpoint, path},
            {:protocol, protocol},
            {:ext, Path.extname(path)},
            {:get, parse_params(endpoint)}
          ]

        [key, value] ->
          [{key, value}]
      end
    end)
  end

  def parse_params(endpoint) do
    case String.contains?(endpoint, "?") do
      true ->
        endpoint
        |> String.split("?")
        |> Enum.at(1)
        |> String.split("&", trim: true)
        |> Enum.map(fn opt ->
          [key, value] = opt |> String.replace(["/", "?"], "") |> String.split("=")
          {key, value}
        end)
        |> Map.new()

      false ->
        %{}
    end
  end
end
