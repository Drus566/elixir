defmodule HospitalApp.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "patients" do
    field :name, :string
    field :age, :integer # Добавили сюда
    field :status, :string, default: "waiting"

    timestamps()
  end

  # Changeset проверяет данные перед записью
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:name,:age,:status]) # разрешаем менять только name
    |> validate_required([:name,:age]) # имя обязательно
    |> validate_inclusion(:age, 18..120)
    |> validate_length(:name, min: 2) # минимум 2 буквы
  end
end
