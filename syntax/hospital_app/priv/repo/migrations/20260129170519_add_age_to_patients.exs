defmodule HospitalApp.Repo.Migrations.AddAgeToPatients do
  use Ecto.Migration

  def change do
    alter table(:patients) do
      # Добавляем колонку age с типом integer
      # default: 18 необязателен, но полезен, чтобы не было пустых значений
      add :age, :integer, default: 18
    end
  end
end
