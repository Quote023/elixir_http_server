defmodule Router do
  def handle_route(request, state \\ %{common: %{}}) do
    # main_context => informações globais do servidor + informações da sessão
    main_context = Map.merge(Map.get(state, :common, %{}), Map.get(state, "{USER_ID_HERE}", %{}))
    IO.inspect(main_context)

    cond do
      String.contains?(request[:raw], "GET /favicon.ico") ->
        {read_static_file("favicon.ico"), state}

      String.contains?(request[:raw], "POST /name ") ->
        name =
          String.split(request[:raw], "\r\n\r\n")
          |> Enum.at(1)
          |> String.split("\r\n", trim: true)
          |> Enum.find(fn txt -> String.contains?(txt, "name=") end)
          |> String.split("=")
          |> Enum.at(1)

        new_state = merge_state(state, %{common: %{name: name}})

        {
          %{headers: %{"Location" => "/"}, status_code: 301},
          new_state
        }

      String.contains?(request[:raw], "POST /delete-name ") ->
        {_, new_state} = pop_in(state, [:common, :name])

        {
          %{headers: %{"Location" => "/"}, status_code: 301},
          new_state
        }

      true ->
        page_context =
          Map.merge(main_context, %{
            title: "Hora Certa do 🍯",
            date: DateTime.utc_now(),
            imgurl:
              "https://i.guim.co.uk/img/media/eda873838f940582d1210dcf51900efad3fa8c9b/0_469_7360_4417/master/7360.jpg?width=1200&height=1200&quality=85&auto=format&fit=crop&s=4136d0378a9d158831c65d13dcc16389",
            name: "Filme Legal",
            director: "Katy Perry",
            releaseyear: "2025",
            classification: "+65",
            gender: "Feminino"
          })

        html =
          read_static_file("index.html")
          |> Map.get(:file)
          |> TemplateParser.parse(page_context)

        {%{content: html}, state}
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
    path = Path.join(:code.priv_dir(:elixir_http_server), "static/#{name}")

    {:ok, file} = File.read(path)
    {:ok, info} = File.stat(path)

    %{file: file, info: info, path: path}
  end
end
