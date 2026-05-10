defmodule BotDiscord.MixProject do
  use Mix.Project

  def project do
    [
      app: :bot_discord,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {BotDiscord.Application, []}
    ]
  end

  defp deps do
    [
      {:nostrum, "~> 0.9"},
      {:tesla, "~> 1.9"},
      {:hackney, "~> 1.20"},
      {:jason, "~> 1.4"}
    ]
  end
end
