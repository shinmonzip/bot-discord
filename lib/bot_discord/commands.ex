defmodule BotDiscord.Commands do
  alias BotDiscord.Store

  # --- Comandos públicos ---

  # Sem parâmetro
  def ping, do: "Pong! 🏓"

  # Um parâmetro — API: wttr.in (clima)
  def clima(cidade) do
    url = "https://wttr.in/#{URI.encode(cidade)}?format=3"

    case http_get(url) do
      {:ok, %{status: 200, body: corpo}} -> String.trim(corpo)
      _ -> "Não consegui obter o clima de **#{cidade}**."
    end
  end

  # Um parâmetro — API: PokéAPI
  def pokemon(nome) do
    nome_normalizado = nome |> String.downcase() |> URI.encode()
    url = "https://pokeapi.co/api/v2/pokemon/#{nome_normalizado}"

    case fetch_json(url) do
      {:ok, dados} ->
        tipos =
          dados["types"]
          |> Enum.map(fn t -> t["type"]["name"] end)
          |> Enum.join(", ")

        altura = dados["height"] / 10
        peso = dados["weight"] / 10

        "**#{String.capitalize(dados["name"])}** | Tipos: #{tipos} | Altura: #{altura}m | Peso: #{peso}kg"

      {:error, :not_found} ->
        "Pokémon \"#{nome}\" não encontrado."

      _ ->
        "Erro ao buscar informações do Pokémon."
    end
  end

  # Dois ou mais parâmetros — API: fawazahmed0/currency-api via jsDelivr (conversão de moedas)
  def conv(valor_str, de, para) do
    moeda_origem = String.downcase(de)
    moeda_destino = String.downcase(para)
    url = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/#{moeda_origem}.json"

    with {valor, _} <- Float.parse(valor_str),
         {:ok, dados} <- fetch_json(url),
         taxas when not is_nil(taxas) <- dados[moeda_origem],
         taxa when not is_nil(taxa) <- taxas[moeda_destino] do
      resultado = Float.round(valor * taxa, 2)
      "#{valor_str} #{String.upcase(de)} = **#{resultado} #{String.upcase(para)}**"
    else
      :error -> "Valor inválido: \"#{valor_str}\". Use um número, ex: `!conv 100 USD BRL`"
      nil -> "Moeda \"#{para}\" não encontrada. Verifique o código da moeda (ex: USD, BRL, EUR)."
      _ -> "Erro ao converter moeda."
    end
  end

  # Dois ou mais parâmetros — API: GitHub REST API
  def github(usuario, repositorio) do
    url = "https://api.github.com/repos/#{URI.encode(usuario)}/#{URI.encode(repositorio)}"
    headers = [{"User-Agent", "BotDiscord/1.0"}, {"Accept", "application/vnd.github.v3+json"}]

    case fetch_json(url, headers) do
      {:ok, dados} ->
        descricao = dados["description"] || "Sem descrição"
        linguagem = dados["language"] || "N/A"
        estrelas = dados["stargazers_count"]

        "**#{dados["full_name"]}** ⭐ #{estrelas}\n#{descricao}\nLinguagem principal: #{linguagem}"

      {:error, :not_found} ->
        "Repositório \"#{usuario}/#{repositorio}\" não encontrado."

      _ ->
        "Erro ao buscar repositório no GitHub."
    end
  end

  # Persistir no JSON
  def lembrar(user_id, texto) do
    Store.add_note(user_id, texto)
    "✅ Anotado! Vou me lembrar disso."
  end

  def lembretes(user_id) do
    notas = Store.get_notes(user_id)

    if Enum.empty?(notas) do
      "Você não tem anotações salvas."
    else
      itens =
        notas
        |> Enum.with_index(1)
        |> Enum.map(fn {nota, i} -> "#{i}. #{nota}" end)
        |> Enum.join("\n")

      "Suas anotações:\n#{itens}"
    end
  end

  # Combinando duas APIs: Nominatim (coordenadas) + Wikipedia (curiosidade)
  def curiosidade(cidade) do
    with {:ok, geo} <- buscar_coordenadas(cidade),
         lat = geo["lat"],
         lon = geo["lon"],
         {:ok, artigo} <- buscar_wikipedia(lat, lon) do
      titulo = artigo["title"]
      trecho = artigo["extract"] |> String.slice(0, 1000)
      "**#{titulo}** (próximo a #{cidade})\n#{trecho}..."
    else
      {:error, :not_found} -> "Cidade \"#{cidade}\" não encontrada."
      _ -> "Não consegui encontrar curiosidades sobre **#{cidade}**."
    end
  end

  # --- Funções privadas ---

  defp buscar_coordenadas(cidade) do
    url = "https://nominatim.openstreetmap.org/search?q=#{URI.encode(cidade)}&format=json&limit=1"
    headers = [{"User-Agent", "BotDiscord/1.0"}, {"Accept-Language", "pt-BR"}]

    case fetch_json(url, headers) do
      {:ok, [geo | _]} -> {:ok, geo}
      {:ok, []} -> {:error, :not_found}
      erro -> erro
    end
  end

  defp buscar_wikipedia(lat, lon) do
    geo_url =
      "https://pt.wikipedia.org/w/api.php?action=query&list=geosearch" <>
        "&gscoord=#{lat}|#{lon}&gsradius=10000&gslimit=1&format=json"

    case fetch_json(geo_url) do
      {:ok, dados} ->
        case get_in(dados, ["query", "geosearch"]) do
          [pagina | _] ->
            titulo = URI.encode(pagina["title"])
            fetch_json("https://pt.wikipedia.org/api/rest_v1/page/summary/#{titulo}")

          _ ->
            {:error, :not_found}
        end

      erro ->
        erro
    end
  end

  defp fetch_json(url, headers \\ []) do
    case http_get(url, headers) do
      {:ok, %{status: 200, body: corpo}} -> Jason.decode(corpo)
      {:ok, %{status: 404}} -> {:error, :not_found}
      _ -> {:error, :request_failed}
    end
  end

  defp http_get(url, headers \\ []) do
    middleware = [{Tesla.Middleware.Headers, headers}]
    cliente = Tesla.client(middleware)
    Tesla.get(cliente, url)
  end
end
