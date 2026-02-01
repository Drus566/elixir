defmodule HospitalApp.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:patients) do
      add :name, :string
      timestamps() # добавит inserted_at и updated_at
    end
  end
end
