
# Cупервизор для управления асинхронными задачами...

# Преимущества
# Конкурентность - множество задач выполняются параллельно
# Изоляция - падение одной задачи не влияет на другие
# Контроль нагрузки - ограничение количества одновременных задач
# Надежность - супервизор перезапустит упавшие задачи
# Удобный API - простой интерфейс для сложной асинхронной обработки

# Типичные use cases:
# Массовая обработка данных
# Параллельные HTTP запросы
# Обработка файлов
# Вычисления, которые можно распараллелить

defmodule ElixirExample.TaskSupervisor do
  use Supervisor # превращает модуль в супервизор

  def start_link(opts) do
    # Регистрируется под именем модуля для глобального доступа
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Task.Supervisor - специальный супервизор для управления задачами
    # Регистрируется под именем ElixirExample.AsyncTaskSupervisor
    children = [
      {Task.Supervisor, name: ElixirExample.AsyncTaskSupervisor}
    ]

    # падает одна задача - перезапускается только она, а не все
    Supervisor.init(children, strategy: :one_for_one)
  end

  def process_list_async(items, processor) when is_list(items) and is_function(processor) do
    # async_stream_nolink - создает поток асинхронных задач,
    # nolink - задачи не связаны с родительским процессом (если задача падает - не влияет на родителя)
    Task.Supervisor.async_stream_nolink(
      ElixirExample.AsyncTaskSupervisor, # супервизор, управляющий задачами
      items, # список элементов для обработки
      processor, # функция-обработчик для каждого элемента
      max_concurrency: System.schedulers_online() * 2 # оптимизация производительности
      # System.schedulers_online() - количество доступных CPU ядер
      # Умножаем на 2 для оптимального использования ресурсов
    )
    # Обработка результатов
    |> Stream.map(fn
      {:ok, result} -> {:ok, result} # (успешное выполнение)
      {:exit, reason} -> {:error, reason} # (ошибка в задаче)
    end)
    |> Enum.to_list() # форсирует выполнение всех задач (до этого момента операции ленивые)
  end
end

# Пример использования
# 1. Запускаем супервизор
# ElixirExample.TaskSupervisor.start_link([])
# 2. Обрабатываем список асинхронно
# items = [1, 2, 3, 4, 5]
# processor = fn x -> x * x end  # функция возведения в квадрат
# results = ElixirExample.TaskSupervisor.process_list_async(items, processor)
# Результат: [{:ok, 1}, {:ok, 4}, {:ok, 9}, {:ok, 16}, {:ok, 25}]


# Еще один пример
# Обработка URL с загрузкой данных
# urls = ["https://example.com/1", "https://example.com/2"]
# processor = fn url ->
#   case HTTPoison.get(url) do
#    {:ok, %{status_code: 200, body: body}} ->
#      {:ok, body}
#    {:ok, %{status_code: code}} ->
#      {:exit, "HTTP error: #{code}"}
#    {:error, reason} ->
#      {:exit, reason}
#   end
# end
# results = ElixirExample.TaskSupervisor.process_list_async(urls, processor)
