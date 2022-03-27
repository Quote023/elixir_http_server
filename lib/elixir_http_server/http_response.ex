defmodule ElixirHttpServer.HttpResponse do
  def new(content, status_code \\ 200, headers \\ %{})

  # Definir o Content-Type p/ arquivos
  def new(%{:file => file, :path => path}, status_code, headers) do
    content_type =
      case Path.extname(path) do
        jpg when jpg in [".jpeg", ".jpg"] -> "image/jpeg"
        tif when tif in [".tif", ".tiff"] -> "image/tiff"
        ".gif" -> "image/gif"
        ".png" -> "image/png"
        ".svg" -> "image/svg+xml"
        ".webp" -> "image/webp"
        ".bmp" -> "image/bmp"
        ".ico" -> "image/vnd.microsoft.icon"
        _ -> "application/octet-stream"
      end

    new(file, status_code, Map.put(headers, "Content-Type", content_type))
  end

  def new(content, status_code, headers) when is_map(content) do
    new(
      Map.get(content, :content, ""),
      Map.get(content, :status_code, status_code),
      Map.merge(headers, Map.get(content, :headers, %{}))
    )
  end

  def new(content, status_code, headers) when is_binary(content) do
    {content_type, headers} = Map.pop(headers, "Content-Type", "text/html")

    """
    HTTP/1.0 #{status_code} OK
    Content-Type: #{content_type}
    Content-Length: #{byte_size(content)}\r\n#{header_to_string(headers)}

    #{content}
    """
  end

  def header_to_string([]) do
    ""
  end

  def header_to_string(headers) do
    headers
    |> Enum.map(fn {key, value} ->
      "#{key}: #{value}"
    end)
    |> Enum.join("\r\n")
  end
end
