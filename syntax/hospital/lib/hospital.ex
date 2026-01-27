defmodule Hospital do
  alias Hospital.Validator

  def admit_patient(name, age) do
    case Validator.check(%{age: age}) do
      {:ok, _} -> "Patient #{name} admitted"
      {:error, _} -> "Patient #{name} is too young"
    end
  end
end

# defmodule Hospital.Registry do
#   alias Hospital.Validator

#   def start do
#     # Запускаем процесс и передаем ему начальное состояние — 0
#     spawn(fn -> loop(0) end)
#   end

#   defp loop(count) do
#     receive do
#       {:admit,name} ->
#         new_count = count + 1
#         IO.puts("Зарегистрирован: #{name}. Всего пациентов: #{new_count}")
#         loop(new_count) #Рекурсия! Процесс снова ждет сообщения с новым числом

#       :get_count ->
#         IO.puts("Сейчас в госпитале: #{count}")
#         loop(count)

#       {:check_age,age}->
#         case Validator.check(%{age: age}) do
#           {:ok, _} -> "Проходите"
#           {:error, _} -> "Вам в десткое отделение"
#         end
#         loop(count)
#     end
#   end
# end
