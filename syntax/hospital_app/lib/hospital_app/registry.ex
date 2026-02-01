defmodule HospitalApp.Registry do
    use GenServer

    alias HospitalApp.{Repo, Patient} # Подключаем базу и схему
    import Ecto.Query

    # Запуск
    def start_link(opts) do
      # opts сейчас приходят как пустой список [] из application.ex
      GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end

    # API
    def admit(attrs), do: GenServer.cast(__MODULE__, {:admit, attrs})
    def get_patients, do: GenServer.call(__MODULE__, :get_all)
    def discharge(id), do: GenServer.cast(__MODULE__, {:discharge, id})
    def update_status(id, new_status), do: GenServer.cast(__MODULE__, {:update_status, id, new_status})

    # В init и handle_info (или там, где ты обновляешь список)
    # Вместо select: p.name, выбираем весь объект p
    @impl true
    def init(_opts) do
        patients = Repo.all(from p in Patient, order_by: [desc: p.inserted_at])
        {:ok, patients}
    end

    @impl true
    def handle_cast({:discharge, id}, _old_list) do
        # 1. Удаляем из базы
        case Repo.get(Patient, id) do
            nil -> :ok
            patient -> Repo.delete!(patient)
        end

        # 2. Берем свежий список и рассылаем всем
        new_list = Repo.all(from p in Patient, order_by: [desc: p.inserted_at])
        Phoenix.PubSub.broadcast(HospitalApp.PubSub, "hospital_updates", {:update_list, new_list})

        {:noreply, new_list}
    end

    @impl true
    def handle_cast({:admit, attrs}, _list) do
      # 1. Сохраняем в базу ровно то, что пришло из формы
      %Patient{}
      |> Patient.changeset(attrs)
      |> Repo.insert!() # Здесь теперь сохранятся и имя, и возраст из формы

      # 2. Получаем обновленный список и рассылаем всем
      new_list = Repo.all(from p in Patient, order_by: [desc: p.inserted_at])
      Phoenix.PubSub.broadcast(HospitalApp.PubSub, "hospital_updates", {:update_list, new_list})

      {:noreply, new_list}
    end

    # Callback
    @impl true
    def handle_cast({:update_status, id, new_status}, _list) do
      patient = Repo.get!(Patient, id)

      patient
      |> Patient.changeset(%{status: new_status})
      |> Repo.update!()

      new_list = Repo.all(from p in Patient, order_by: [desc: p.inserted_at])
      Phoenix.PubSub.broadcast(HospitalApp.PubSub, "hospital_updates", {:update_list, new_list})
      {:noreply, new_list}
    end

    @impl true
    def handle_call(:get_all, _from, list) do
      {:reply, list, list}
    end


  end
