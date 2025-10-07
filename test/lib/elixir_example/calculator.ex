# Состояние изолировано в процессе
# Синхронные вызовы гарантируют последовательность операций
# Статистика автоматически обновляется при каждой операции

defmodule ElixirExample.Calculator do
  use GenServer

  # Клиентский API
  # Запускает процесс GenServer
  # opts могут содержать имя процесса и другие параметры
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end


  # Клиентские функции для взаимодействия с сервером
  # GenServer.call - синхронный вызов (ждет ответа)
  # pid - идентификатор процесса сервера
  def add(pid, a, b), do: GenServer.call(pid, {:add, a, b})
  def multiply(pid, a, b), do: GenServer.call(pid, {:multiply, a, b})
  def factorial(pid, n), do: GenServer.call(pid, {:factorial, n})
  def get_stats(pid), do: GenServer.call(pid, :get_stats)

  # Серверный API (callbacks)
  # Создает начальное состояние: счетчик операций и последний результат
  @impl true
  def init(:ok) do
    {:ok, %{operations_count: 0, last_result: nil}}
  end

  # Паттерн-матчинг по типу операции
  # Вычисляет результат и обновляет статистику
  # Возвращает: {:reply, ответ_клиенту, новое_состояние}
  @impl true
  def handle_call({:add, a, b}, _from, state) do
    result = a + b
    new_state = update_stats(state, "add", result)
    {:reply, {:ok, result}, new_state}
  end

    @impl true
  def handle_call({:multiply, a, b}, _from, state) do
    result = a * b
    new_state = update_stats(state, "multiply", result)
    {:reply, {:ok, result}, new_state}
  end

  @impl true
  def handle_call({:factorial, n}, _from, state) when n >= 0 do
    result = calculate_factorial(n)
    new_state = update_stats(state, "factorial", result)
    {:reply, {:ok, result}, new_state}
  end

  @impl true
  def handle_call({:factorial, n}, _from, state) do
    {:reply, {:error, "Number must be non-negative"}, state}
  end

  @impl true
  def handle_call(:get_stats, _from, state) do
    {:reply, state, state}
  end

  # Вспомогательные функции
  defp calculate_factorial(0), do: 1
  defp calculate_factorial(n), do: n * calculate_factorial(n - 1)

  # Обновляет состояние: увеличивает счетчик и сохраняет результат
  defp update_stats(state, _operation, result) do
    %{
      operations_count: state.operations_count + 1,
      last_result: result
    }
  end
end
