defmodule BotDiscord.Consumer do
  use Nostrum.Consumer

  alias BotDiscord.Commands
  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    handle_message(msg)
  end

  def handle_event(_event), do: :noop

  # Ignora mensagens de outros bots
  defp handle_message(%{author: %{bot: true}}), do: :ok

  # !ping — sem parâmetro
  defp handle_message(%{content: "!ping"} = msg) do
    Api.create_message(msg.channel_id, Commands.ping())
  end

  # !lembretes — sem parâmetro (lista anotações)
  defp handle_message(%{content: "!lembretes"} = msg) do
    resposta = Commands.lembretes(msg.author.id)
    Api.create_message(msg.channel_id, resposta)
  end

  # !clima <cidade> — um parâmetro
  defp handle_message(%{content: "!clima " <> cidade} = msg) do
    resposta = Commands.clima(cidade)
    Api.create_message(msg.channel_id, resposta)
  end

  # !pokemon <nome> — um parâmetro
  defp handle_message(%{content: "!pokemon " <> nome} = msg) do
    resposta = Commands.pokemon(nome)
    Api.create_message(msg.channel_id, resposta)
  end

  # !lembrar <texto> — persistência JSON
  defp handle_message(%{content: "!lembrar " <> texto} = msg) do
    resposta = Commands.lembrar(msg.author.id, texto)
    Api.create_message(msg.channel_id, resposta)
  end

  # !curiosidade <cidade> — combina duas APIs
  defp handle_message(%{content: "!curiosidade " <> cidade} = msg) do
    resposta = Commands.curiosidade(cidade)
    Api.create_message(msg.channel_id, resposta)
  end

  # !conv <valor> <moeda_origem> <moeda_destino> — dois ou mais parâmetros
  defp handle_message(%{content: "!conv " <> args} = msg) do
    case String.split(args, " ", parts: 3) do
      [valor, de, para] ->
        resposta = Commands.conv(valor, de, para)
        Api.create_message(msg.channel_id, resposta)

      _ ->
        Api.create_message(
          msg.channel_id,
          "Uso: `!conv <valor> <moeda_origem> <moeda_destino>`\nExemplo: `!conv 100 USD BRL`"
        )
    end
  end

  # !github <usuario> <repositorio> — dois parâmetros
  defp handle_message(%{content: "!github " <> args} = msg) do
    case String.split(args, " ", parts: 2) do
      [usuario, repositorio] ->
        resposta = Commands.github(usuario, repositorio)
        Api.create_message(msg.channel_id, resposta)

      _ ->
        Api.create_message(
          msg.channel_id,
          "Uso: `!github <usuario> <repositorio>`\nExemplo: `!github elixir-lang elixir`"
        )
    end
  end

  # Ignora qualquer outra mensagem
  defp handle_message(_msg), do: :ok
end
