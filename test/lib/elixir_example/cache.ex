
# Все данные хранятся в состоянии процесса
# Каждый вызов изменяет/читает это состояние
# Состояние изолировано и thread-safe

# Простая и эффективная реализация
# Автоматическая обработка конкурентного доступа
# Четкое разделение синхронных/асинхронных операций
# Удобный API через именованную регистрацию

defmodule ElixirExample.Cache do
  use GenServer

  # Клиентский API
  def start_link(opts \\ []) do
    # Важно: используется name: __MODULE__ - регистрирует процесс под именем модуля
    # Теперь можно обращаться к кэшу по имени, а не по PID

    # Вместо этого:
    # {:ok, pid} = ElixirExample.Cache.start_link()
    # ElixirExample.Cache.put(pid, :user, "John")

    # Можно так:
    # ElixirExample.Cache.start_link()
    # ElixirExample.Cache.put(:user, "John")  # Используется зарегистрированное имя

    GenServer.start_link(__MODULE__, %{}, opts ++ [name: __MODULE__])
  end


  # GenServer.cast - асинхронные вызовы (не ждут ответа)
  # Подходят для операций изменения состояния
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})
  # GenServer.call - синхронные вызовы (ждут ответа)
  # Подходят для операций чтения
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def delete(key), do: GenServer.cast(__MODULE__, {:delete, key})
  def clear, do: GenServer.cast(__MODULE__, :clear)
  def size, do: GenServer.call(__MODULE__, :size)

  # Серверный API
  @impl true
  def init(state) do
    # Начальное состояние - пустая mapa %{}
    # Ключ → значение хранятся в состоянии процесса
    {:ok, state}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    # Map.put добавляет или обновляет значение по ключу
    # Возвращает {:noreply, новое_состояние}
    {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  @impl true
  def handle_cast(:clear, _state) do
    # Игнорирует текущее состояние, возвращает пустую map
    {:noreply, %{}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    # Map.get возвращает nil если ключ не найден
    # Возвращает {:reply, ответ, состояние}
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_call(:size, _from, state) do
    # map_size - встроенная функция для получения размера map
    {:reply, map_size(state), state}
  end
end
