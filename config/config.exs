import Config

# Adaptador HTTP padrão do Tesla
config :tesla, adapter: Tesla.Adapter.Hackney

# Intents necessários para ler mensagens no Discord
config :nostrum,
  gateway_intents: [
    :guild_messages,
    :message_content,
    :direct_messages
  ]
