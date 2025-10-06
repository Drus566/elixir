defmodule ElixirExample.MixProject do # Создаем модуль с именем ElixirExample.MixProject
  use Mix.Project # Подключает функции для работы с Mix проектами

  def project do # Функция
    [
      app: :elixir_example, # атом-имя приложения (должен совпадать с именем подуля)
      version: "0.1.0", # версия приложения в формате SemVer
      elixir: "~> 1.14", # Требования к версии elixir
      start_permanent: Mix.env == :prod, # Запускать в режиме "permanent" только в production (в режиме permanent если главный процесс умирает, вся система завершается)
      deps: deps() # Список зависимостей
    ]
  end

  def application do
    [
      extra_applications: [:logger], # Стандартные ОТР-приложения, которые должны запускаться
      mod: {ElixirExample.Application, []} # Указывает точку входа в приложение (callback модуль)
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.0"}, # HTTP клиент для Elixir
      {:jason, "~> 1.4"} # быстрый JSON парсер/генератор
    ]
  end
end

# Mix читает этот файл чтобы понять как собрать проект
# Загружаются зависимости из Hex.pm (пакетный менеджер Elixir)
# Компилируется код из папки lib/
# Запускается приложение через указанный модуль ElixirExample.Application

# Пример рабочего процесса
# # 1. Создать проект
# mix new my_blog
# 2. Добавить зависимости в mix.exs
# {:ecto, "~> 3.0"}, {:phoenix, "~> 1.7"}
# 3. Установить зависимости
# mix deps.get
# 4. Запустить тесты
# mix test
# 5. Запустить приложение
# mix phx.server
# 6. Проверить код
# mix format
# mix credo

#---
