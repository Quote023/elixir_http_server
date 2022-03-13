defmodule ElixirHttpServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_http_server,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_options: [debug_info: Mix.env() == :dev],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirHttpServer, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
