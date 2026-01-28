defmodule Hospital.Registry do
    alias Hospital.Validator

    use GenServer # Магия OTP начинается здесь

    # --- Client API (Функции, которые мы вызываем из консоли) ---

    def start_link(opts) do
        # Третий аргумент :name — это то, что позволяет нам НЕ использовать PID
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end

    def admit(name) do
        # cast — асинхронно ("отправил и забыл")
        GenServer.cast(__MODULE__, {:admit, name})
    end

    def get_count do
        # call — синхронно (ждем ответа!)
        GenServer.call(__MODULE__, :get_count)
    end

    # --- Server Callbacks (Внутренняя логика, которую вызывает сам OTP) ---

    @impl true
    def init(initial_count) do
        {:ok,initial_count} # Устанавливаем начальное состояние
    end

    @impl true
    def handle_cast({:admit, name}, count) do
        IO.puts("Регистрируем #{name}...")
        {:noreply, count+1} # Обновляем состояние на +1
    end

    @impl true
    def handle_call(:get_count, _from, count) do
        {:reply, count, count} # Возвращаем count клиенту
    end

    @impl true
    def handle_call(:check_error, age) do
        case Validator.check(%{age: age}) do
            {:ok, _} -> "Проходите"
            {:error, _} -> "Вам в десткое отделение"
        end
    end
end
