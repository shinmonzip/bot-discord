# BotDiscord

Bot para Discord desenvolvido em Elixir com o framework [Nostrum](https://github.com/Kraigie/nostrum).

## Comandos disponíveis

| Comando | Exemplo | Descrição |
|---|---|---|
| `!ping` | `!ping` | Verifica se o bot está online |
| `!clima <cidade>` | `!clima Fortaleza` | Mostra o clima atual da cidade |
| `!pokemon <nome>` | `!pokemon pikachu` | Exibe informações de um Pokémon |
| `!conv <valor> <de> <para>` | `!conv 100 USD BRL` | Converte entre moedas |
| `!github <user> <repo>` | `!github elixir-lang elixir` | Informações de um repositório público |
| `!lembrar <texto>` | `!lembrar Reunião às 10h` | Salva uma anotação (persiste em JSON) |
| `!lembretes` | `!lembretes` | Lista suas anotações salvas |
| `!curiosidade <cidade>` | `!curiosidade Fortaleza` | Busca uma curiosidade sobre a cidade (combina Nominatim + Wikipedia) |

## Pré-requisitos

- Elixir 1.14+
- Erlang/OTP 25+

## Configuração do Bot no Discord

1. Acesse o [Discord Developer Portal](https://discord.com/developers/applications)
2. Crie uma nova aplicação e vá em **Bot**
3. Gere o token do bot e copie-o
4. Em **Privileged Gateway Intents**, ative **Message Content Intent**
5. Convide o bot para o servidor usando o link gerado em **OAuth2 → URL Generator** com as permissões `bot` e `Send Messages`

## Instalação e execução

```bash
# Instalar dependências
mix deps.get

# Configurar o token (substitua pelo token real)
export DISCORD_TOKEN="seu_token_aqui"

# Executar o bot
mix run --no-halt
```

## Estrutura do projeto

```
lib/
  bot_discord/
    application.ex   # Ponto de entrada e supervisor principal
    consumer.ex      # Handler de eventos do Discord (despacho via pattern matching)
    commands.ex      # Implementação de cada comando
    store.ex         # Persistência de dados em JSON (GenServer)
config/
  config.exs         # Configurações gerais (adapter HTTP, gateway intents)
  runtime.exs        # Token lido da variável de ambiente em tempo de execução
```

## APIs utilizadas

- **wttr.in** — clima (sem chave)
- **PokéAPI** — dados de Pokémon (sem chave)
- **frankfurter.app** — conversão de moedas (sem chave)
- **GitHub REST API** — dados de repositórios públicos (sem chave)
- **Nominatim (OpenStreetMap)** — geolocalização (sem chave)
- **Wikipedia REST API** — curiosidades geográficas (sem chave)
