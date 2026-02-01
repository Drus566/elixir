defmodule HospitalAppWeb.HospitalLive do
  use HospitalAppWeb, :live_view

  # Импортируем наши модули
  alias HospitalApp.{Registry, Patient, Repo}


  # И добавь вспомогательную функцию (вне render, но внутри модуля):
  defp status_color("waiting"), do: "bg-yellow-50 border-yellow-200"
  defp status_color("in_progress"), do: "bg-green-50 border-green-200"
  defp status_color(_), do: "bg-gray-50 border-gray-200"
  defp filtered_patients(patients, filter, search) do
    patients
    |> Enum.filter(fn p ->
      # Фильтр по статусу
      status_match = (filter == "all" or p.status == filter)
      # Фильтр по имени (без учета регистра)
      name_match = String.contains?(String.downcase(p.name), String.downcase(search))

      status_match and name_match
    end)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(HospitalApp.PubSub, "hospital_updates")

    patients = Registry.get_patients()
    changeset = Patient.changeset(%Patient{}, %{})

    {:ok,
     socket
     |> assign(:patients, patients)
     |> assign(:form, to_form(changeset))
     |> assign(:filter, "all")
     |> assign(:search, "")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto mt-10 p-6 bg-white rounded-xl shadow-md">
      <h1 class="text-2xl font-bold text-gray-800 mb-6">Приемный покой</h1>

      <.form for={@form} phx-change="validate" phx-submit="add_patient" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700">Имя пациента</label>
          <.input field={@form[:name]} placeholder="Напр. Иван Иванов"
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Возраст</label>
          <.input field={@form[:age]} type="number" placeholder="18+"
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
        </div>

        <button type="submit"
                class="w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 transition">
          Зарегистрировать
        </button>
      </.form>

      <div class="flex space-x-2 mb-6 bg-gray-100 p-1 rounded-lg">
        <%= for f <- ["all", "waiting", "in_progress"] do %>
          <button
            phx-click="set_filter"
            phx-value-filter={f}
            class={"flex-1 py-1 text-sm rounded-md transition #{if @filter == f, do: "bg-white shadow text-indigo-600 font-bold", else: "text-gray-500 hover:text-gray-700"}"}>
            <%= case f do
              "all" -> "Все"
              "waiting" -> "Очередь"
              "in_progress" -> "В кабинете"
            end %>
          </button>
        <% end %>
      </div>

      <div class="mb-4">
        <input
          type="text"
          name="search"
          value={@search}
          phx-keyup="search_patients"
          placeholder="Поиск пациента по имени..."
          class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <div class="mt-10">
        <h2 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Список в очереди</h2>
        <ul id="patients-list" class="divide-y divide-gray-200">
          <%= for patient <- filtered_patients(@patients, @filter, @search) do %>
            <div class={"p-4 mb-2 border rounded-lg #{status_color(patient.status)}"}>
              <div class="flex justify-between items-center">
                <div>
                  <span class="font-bold text-lg"><%= patient.name %></span>
                  <span class="text-sm ml-2">(<%= patient.age %> лет)</span>
                  <p class="text-xs uppercase font-semibold">Статус: <%= patient.status %></p>
                </div>

                <div class="space-x-2">
                  <%= if patient.status == "waiting" do %>
                    <button phx-click="set_status" phx-value-id={patient.id} phx-value-status="in_progress"
                            class="bg-green-500 text-white px-3 py-1 rounded text-sm">
                      Пригласить в кабинет
                    </button>
                  <% end %>

                  <%= if patient.status == "in_progress" do %>
                    <button phx-click="discharge_patient" phx-value-id={patient.id}
                            class="bg-blue-500 text-white px-3 py-1 rounded text-sm">
                      Завершить прием
                    </button>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("search_patients", %{"value" => value}, socket) do
    {:noreply, assign(socket, search: value)}
  end

  @impl true
  def handle_event("set_filter", %{"filter" => f}, socket) do
    {:noreply, assign(socket, filter: f)}
  end

  @impl true
  def handle_event("set_status", %{"id" => id, "status" => status}, socket) do
    Registry.update_status(id, status)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"patient" => params}, socket) do
    # Создаем changeset и помечаем его как :validate, чтобы ошибки отобразились
    changeset =
      %Patient{}
      |> Patient.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("discharge_patient", %{"id" => id}, socket) do
    Registry.discharge(id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_list, new_list}, socket) do
    {:noreply, assign(socket, patients: new_list)}
  end

  @impl true
  def handle_event("add_patient", %{"patient" => params}, socket) do
    # Проверяем валидность просто для формы
    changeset = Patient.changeset(%Patient{}, params)

    if changeset.valid? do
      # Отправляем ВСЕ параметры в Registry
      Registry.admit(params)

      # Сбрасываем форму
      {:noreply, assign(socket, form: to_form(Patient.changeset(%Patient{}, %{})))}
    else
      # Если есть ошибки валидации (например, возраст < 18), просто показываем их
      {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  # Слушаем сообщения от Registry через PubSub
  def handle_info({:patient_added, new_list}, socket) do
    {:noreply, assign(socket, patients: new_list)}
  end
end
