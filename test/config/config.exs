# конфигурационный файл для Elixir приложения

# Современный способ импорта функций конфигурации (вместо устаревшего use Mix.Config)
# Позволяет использовать функции config/2, config/3 и другие

# Преимущества
# Централизация - все настройки в одном месте
# Среданезависимость - разные настройки для dev/prod/test
# Читаемость - понятная структура конфигурации
# Гибкость - легко менять настройки без изменения кода
# Стандартизация - единый формат логирования во всем приложении

# Типичное расположение: config/config.exs (корневой файл), с импортом специфичных для среды файлов:
# config/dev.exs
# config/prod.exs
# config/test.exs

import Config

config :elixir_example, # имя вашего приложения (обычно соответствует имени в mix.exs)
  cache_ttl: 3600 # кастомная настройка Time-To-Live для кэша в секундах

# Пример использования cache_ttl в коде
#  defmodule ElixirExample.Cache do
#  def get_ttl do
#    Application.get_env(:elixir_example, :cache_ttl, 1800)  # 1800 - значение по умолчанию
#  end
# end

# конфигурация логов
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id] # включает ID запроса в логи. Полезно для трассировки запросов в распределенных системах

# $time - временная метка
# $metadata[$level] - метаданные и уровень логирования в квадратных скобках
# $message - сообщение лога

# Пример вывода
# 14:30:25.123 request_id=abc123[info] Request processed successfully
# 14:30:26.456 request_id=def456[error] Database connection failed
