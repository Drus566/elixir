defmodule HospitalAppWeb.HospitalLive do
  use HospitalAppWeb, :live_view
  alias HospitalApp.Registry

  # 1. Вызывается при первом открытии страницы
  def mount(_params, _session, socket) do
    # Берем текущий список пациентов из нашего GenServer
    patients = Registry.get_patients()
    # Сохраняем их в "состояние" страницы (socket)
    {:ok, assign(socket, patients: patients, name: "")}
  end

  # 2. Рендерим HTML (прямо в файле для удобства)
  def render(assigns) do
    ~H"""
    <h1>Приемный покой</h1>

    <form phx-submit="add_patient">
      <input type="text" name="patient_name" value={@name} placeholder="Имя пациента" />
      <button type="submit">Добавить</button>
    </form>

    <ul>
      <%= for name <- @patients do %>
        <li><%= name %></li>
      <% end %>
    </ul>
    """
  end

  # 3. Обработка нажатия кнопки
  def handle_event("add_patient", %{"patient_name" => name}, socket) do
    # Отправляем данные в наш OTP процесс
    Registry.admit(name)

    # Обновляем список в сокете, чтобы страница перерисовалась
    new_patients = Registry.get_patients()
    {:noreply, assign(socket, patients: new_patients)}
  end
end
