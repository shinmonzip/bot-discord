import Config

# Leiutura do Token do meu bot do Discord a partir de uma variável de ambiente
config :nostrum,
  token: System.fetch_env!("DISCORD_TOKEN")
