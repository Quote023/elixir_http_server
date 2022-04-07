defmodule Router do
  def handle_route(request, state \\ %{common: %{}}) do
    # main_context => informações globais do servidor + informações da sessão
    main_context =
      Map.get(state, :common, %{})
      |> Map.merge(Map.get(state, :system, %{}))
      |> Map.put(:request, request)

    # |> Map.merge(Map.get(state, "{USER_ID_HERE}", %{}))

    IO.inspect(request)

    cond do
      is_post(request) and request.endpoint === "/name" ->
        name =
          request.body
          |> String.split("\r\n", trim: true)
          |> Enum.find(fn txt -> String.contains?(txt, "name=") end)
          |> String.split("=")
          |> Enum.at(1)

        new_state = merge_state(state, %{common: %{name: name}})

        {
          %{headers: %{"Location" => "/"}, status_code: 301},
          new_state
        }

      is_post(request) and request.endpoint === "/delete-name" ->
        {_, new_state} = pop_in(state, [:common, :name])

        {
          %{headers: %{"Location" => "/"}, status_code: 301},
          new_state
        }

      is_get(request) and (request.ext === ".html" or request.ext === "") ->
        file_path = if request[:endpoint] === "/", do: "index.html", else: request[:endpoint]
        file_data = read_static_file(file_path)

        data =
          with file when is_binary(file) <- Map.get(file_data, :file, nil) do
            html = TemplateParser.parse(file, main_context)
            %{content: html}
          else
            _ -> file_data
          end

        {data, state}

      request[:method] === "GET" ->
        {read_static_file(request[:endpoint]), state}

      true ->
        {%{content: "<h1>404<h1>"}, state}
    end
  end

  defp merge_state(st1, st2) do
    Map.merge(st1, st2, &recur_map_merge/3)
  end

  defp recur_map_merge(_key, v1, v2) do
    if is_map(v1) and is_map(v2) do
      Map.merge(v1, v2, &recur_map_merge/3)
    else
      v2
    end
  end

  defp read_static_file(name) do
    path =
      Path.join(
        :code.priv_dir(:elixir_http_server),
        "static/#{name |> String.split("?") |> Enum.at(0) |> String.trim("/")}"
      )

    case File.read(path) do
      {:ok, file} ->
        case File.stat(path) do
          {:ok, info} ->
            %{file: file, info: info, path: path}

          {:error, reason} ->
            %{
              content: "<header><h1>Erro Inesperado</h1><h2>#{reason}</h2></header>",
              status_code: 500
            }
        end

      {:error, reason} ->
        %{
          content: "<header><h1>Um Erro Aconteceu</h1><h2>#{reason}</h2></header>",
          status_code: 404
        }
    end
  end

  defp is_get(request), do: Map.get(request, :method, "") === "GET"
  defp is_post(request), do: Map.get(request, :method, "") === "POST"
end
