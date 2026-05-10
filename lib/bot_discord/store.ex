defmodule BotDiscord.Store do
  use GenServer

  @file_path "notes.json"

  # --- API pública ---

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_note(user_id, texto) do
    GenServer.call(__MODULE__, {:add_note, user_id, texto})
  end

  def get_notes(user_id) do
    GenServer.call(__MODULE__, {:get_notes, user_id})
  end

  # --- Callbacks do GenServer ---

  @impl true
  def init(_) do
    estado = ler_arquivo()
    {:ok, estado}
  end

  @impl true
  def handle_call({:add_note, user_id, texto}, _from, estado) do
    chave = to_string(user_id)
    notas = Map.get(estado, chave, [])
    novo_estado = Map.put(estado, chave, notas ++ [texto])
    salvar_arquivo(novo_estado)
    {:reply, :ok, novo_estado}
  end

  @impl true
  def handle_call({:get_notes, user_id}, _from, estado) do
    chave = to_string(user_id)
    notas = Map.get(estado, chave, [])
    {:reply, notas, estado}
  end

  # --- Funções privadas ---

  defp ler_arquivo do
    case File.read(@file_path) do
      {:ok, conteudo} ->
        case Jason.decode(conteudo) do
          {:ok, dados} -> dados
          _ -> %{}
        end

      _ ->
        %{}
    end
  end

  defp salvar_arquivo(estado) do
    conteudo = Jason.encode!(estado, pretty: true)
    File.write!(@file_path, conteudo)
  end
end
