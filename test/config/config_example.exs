# === Пример конфига ===
import Config

# Настройки приложения
config :elixir_example,
  cache_ttl: 3600,
  max_connections: 100,
  api_timeout: 30000

# Настройки базы данных
config :elixir_example, ElixirExample.Repo,
  database: "my_app_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

# Настройки логгера
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id, :module]

# Уровень логирования в зависимости от среды
if config_env() == :prod do
  config :logger, level: :info
else
  config :logger, level: :debug
end


# === Использование в коде ===
defmodule ElixirExample.APIClient do
  def make_request(url) do
    timeout = Application.get_env(:elixir_example, :api_timeout, 3000)

    Logger.info("Making API request",
      metadata: [url: url, timeout: timeout]
    )

    # Лог будет: "14:30:25.123 url=https://api.example.com timeout=5000[info] Making API request"
  end
end

# === Особенности конфигурации ===
# Можно использовать условия
if config_env() == :dev do
  config :elixir_example, debug_mode: true
end

# Или импортировать другие файлы
import_config "#{config_env()}.exs"

# === Получение настроек ===
# Способ 1: Application.get_env/3
ttl = Application.get_env(:elixir_example, :cache_ttl)

# Способ 2: Через модуль приложения
defmodule ElixirExample.Config do
  def cache_ttl, do: Application.get_env(:elixir_example, :cache_ttl)
end
