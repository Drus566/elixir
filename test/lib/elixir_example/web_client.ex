
# Реализует HTTP клиент для работы с JSONPlaceholder API через GenServer
defmodule ElixirExample.WebClient do
  use GenServer

  @api_base "https://jsonplaceholder.typicode.com" # API предоставляет тестовые данные (посты, пользователи и т.д.)

  def start_link(opts \\ []) do
    # Принимает опции и передает их в init и при регистрации процесса
    GenServer.start_link(__MODULE__, opts, opts)
  end

  # Синхронные вызовы для получения данных
  def fetch_posts(pid), do: GenServer.call(pid, :fetch_posts)
  def fetch_post(pid, id), do: GenServer.call(pid, {:fetch_post, id})

  @impl true
  def init(opts) do
    # Состояние просто передает полученные опции
    # Можно использовать для хранения конфигурации, таймаутов и т.д.
    {:ok, opts}
  end

  @impl true
  def handle_call(:fetch_posts, _from, state) do
    case HTTPoison.get("#{@api_base}/posts") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        posts = Jason.decode!(body)
        {:reply, {:ok, posts}, state}

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:reply, {:error, "HTTP error: #{status}"}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:fetch_post, id}, _from, state) do
    case HTTPoison.get("#{@api_base}/posts/#{id}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        post = Jason.decode!(body)
        {:reply, {:ok, post}, state}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:reply, {:error, "Post not found"}, state}

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:reply, {:error, "HTTP error: #{status}"}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end
end

# Пример использования
# Запуск клиента
# {:ok, client} = ElixirExample.WebClient.start_link()
# Получение всех постов
# case ElixirExample.WebClient.fetch_posts(client) do
#  {:ok, posts} ->
#    IO.puts("Received #{length(posts)} posts")
#  {:error, reason} ->
#    IO.puts("Error: #{reason}")
# end

# Получение конкретного поста
# case ElixirExample.WebClient.fetch_post(client, 1) do
#  {:ok, post} ->
#    IO.puts("Post title: #{post["title"]}")
#  {:error, reason} ->
#    IO.puts("Error: #{reason}")
# end
