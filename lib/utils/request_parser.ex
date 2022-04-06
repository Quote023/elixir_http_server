defmodule RequestParser do
  def parse(request) do
    req = request|> String.split("\r\n\r\n", trim: true)
    Enum.at(req, 0)
    |>String.split("\r\n", trim: true)
    |>Enum.map(fn x -> String.split(x, ":", parts: 2) end)
    |>Map.new(fn x ->
        if (length(x) == 1 ) do
            [key,value, value2] = String.split(List.first(x), " ", parts: 3)
            {key, [value, value2]}

        else
          [key,value] = x
          {key, value}
          end
    end )

  |>Map.put(:raw, request)
  |>Map.put(:body, Enum.at(req, 1, ""))
  end
end
