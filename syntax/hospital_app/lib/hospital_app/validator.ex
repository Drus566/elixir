defmodule HospitalApp.Validator do # Хорошая практика — добавлять имя проекта в название модуля
  def check(%{age: age}) when age >= 18, do: {:ok, "Welcome"}
  def check(_), do: {:error, "Too young"}
end
