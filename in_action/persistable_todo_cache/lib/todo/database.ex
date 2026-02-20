defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__) # Локальная регистрация процесса
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    File.mkdir_p!(@db_folder) # Проверка что такая папка существует
    {:ok, nil}
  end

  def handle_cast({:store, key, data}, state) do
    # Обрабатывается в порожденном процессе
    spawn(fn ->
      key
      |> file_name()
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, state}
  end

  # caller - pid вызывающего процесса
  def handle_call({:get, key}, caller, state) do
    # Порождение процесса для считывания данных
    spawn(fn ->
      data = case File.read(file_name(key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

      # Отправляем ответ по pid вызывающего процесса
      GenServer.reply(caller,data) # Отправка ответа от порожденного процесса
    end)

    {:noreply,state} # Процесс БД ответ не отправляет
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
