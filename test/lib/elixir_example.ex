defmodule ElixirExample do
  @moduledoc """
  Основной модуль приложения с примерами использования.
  """

  alias Hex.API
  alias ElixirExample.{Calculator, Cache, WebClient, TaskSupervisor}

  def demo do
    IO.puts("=== Демонстрация Elixir проекта ===\n")

    # Демонстрация калькулятора
    {:ok, calc_pid} = Calculator.start_link()
    demo_calculator(calc_pid)

    # Демонстрация кэша
    demo_cache()

    # Демонстрация асинхронной обработки
    demo_async_processing()

    # Демонстрация работы с веб-API
    demo_web_client()

    IO.puts("\n=== Демонстрация завершена ===")
  end


  def demo_calculator(pid) do
    IO.puts("1. Демонстрация калькулятора:")

    {:ok, result} = Calculator.add(pid, 5, 3)
    IO.puts("    5 + 3 = #{result}")

    {:ok, result} = Calculator.multiply(pid, 4, 7)
    IO.puts("    4 * 7 = #{result}")

    {:ok, result} = Calculator.factorial(pid, 5)
    IO.puts("    factorial(5) = #{result}")

    stats = Calculator.get_stats(pid)
    IO.puts("    Статистика: #{inspect(stats)}")
    IO.puts("")
  end

  defp demo_cache do
    IO.puts("2. Демонстрация кэша:")

    Cache.put(:user_1, %{name: "John", age: 30})
    Cache.put(:user_2, %{name: "Jane", age: 25})
    Cache.put(:config, %{theme: "dark", language: "ru"})

    user1 = Cache.get(:user_1)
    IO.puts("    User 1: #{inspect(user1)}")

    cache_size = Cache.size()
    IO.puts("    Размер кэша: #{cache_size}")

    Cache.delete(:user_2)
    new_size = Cache.size()
    IO.puts("    Размер после удаления: #{new_size}")
    IO.puts("")
  end

  defp demo_async_processing do
    IO.puts("3. Демонстрация асинхронной обработки:")
    numbers = 1..10 |> Enum.to_list()
    processor = fn n ->
      Process.sleep(100) # Имитация тяжелой операции
      n * n
    end

    results = TaskSupervisor.process_list_async(numbers, processor)
    squared_numbers = for {:ok, result} <- results, do: result

    IO.puts("   Квадраты чисел 1..10: #{inspect(squared_numbers)}")
    IO.puts("")
  end

  defp demo_web_client do
    IO.puts("4. Демонстрация веб-клиента:")

    {:ok, web_pid} = WebClient.start_link()

    case WebClient.fetch_post(web_pid, 1) do
      {:ok, post} ->
        IO.puts("   Получен пост:")
        IO.puts("   Заголовок: #{post["title"]}")
        IO.puts("   Автор: User ##{post["userId"]}")

      {:error, reason} ->
        IO.puts("   Ошибка: #{reason}")
    end
  end
end
