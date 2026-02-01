defmodule HospitalApp.Repo.Migrations.AddStatusToPatients do
  use Ecto.Migration

  def change do
    alter table(:patients) do
      # Используем строку для статуса
      add :status, :string, default: "waiting"
    end
  end
end
