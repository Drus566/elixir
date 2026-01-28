defmodule HospitalApp.Repo do
  use Ecto.Repo,
    otp_app: :hospital_app,
    adapter: Ecto.Adapters.Postgres
end
