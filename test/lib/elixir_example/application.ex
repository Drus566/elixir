defmodule ElixirExample.Application do
  use Application # Подключает поведение OTP Application, добавляет необходимые callback функции, делает модуль главной точкой входа приложения

  @impl true # Указывает что это реализация callback функции из поведения Application
  def start(_type, _args) do # _type - тип запуска (:normal, :takeover, :failover), _args - аргументы
    children = [ # Список дочерних процессов
      ElixirExample.Cache, # Простой GenServer - запустится с start_link() без аргументов
      ElixirExample.TaskSupervisor, # Кастомный супервизор для управления Task процессами
      {DynamicSupervisor, strategy: :one_for_one, name: ElixirExample.DynamicSupervisor} # Супервизор для динамического создания процессов
      # Стратегия если процесс умирает, перезапускается только он
      # ElixirExample.DynamicSupervisor, регистрирует имя для глобального доступа
    ]

    opts = [strategy: :one_for_one, name: ElixirExample.Supervisor] # Опции
    # :one_for_one, если умирает перезапускается только он
    # :one_for_all, если умирает, перезапускаются все
    # :rest_for_one, если умирает, перезапускаются процессы, запущенные после него
    Supervisor.start_link(children, opts) # Запуск супервизора

    # Запускается главный супервизор
    # Супервизор запускает всех детей в указанном порядке
    # Создаётся дерево процессов:

# ElixirExample.Supervisor (главный супервизор)
# |── ElixirExample.Cache (GenServer)
# ├── ElixirExample.TaskSupervisor (Supervisor)
# └── ElixirExample.DynamicSupervisor (DynamicSupervisor)

  end
end
