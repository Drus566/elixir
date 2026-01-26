defmodule Hospital do
  alias Hospital.Validator

  def admit_patient(name, age) do
    case Validator.check(%{age: age}) do
      {:ok, _} -> "Patient #{name} admitted"
      {:error, _} -> "Patient #{name} is too young"
    end
  end
end
