defmodule TemplateParser do
  @pattern ~r/{{[\s\S]+?}}/
  @delimiters ["{{", "}}"]

  def parse(html, ctx) do
    Regex.scan(@pattern, html)
    |> List.flatten()
    |> Enum.reduce(html, fn code_str, acc -> evaluate_and_replace(code_str, acc, ctx) end)
  end

  defp evaluate_and_replace(code, html, ctx) do
    result =
      code
      |> String.replace(@delimiters, "")
      |> Code.eval_string(ctx: ctx)
      |> elem(0)

    String.replace(html, code, result)
  end
end
