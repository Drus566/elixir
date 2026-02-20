defmodule ListHelper do
	def smallest(list) when length(list) > 0 do
	#def smallest(list) do
		Enum.min(list)
	end
	
	def smallest(_), do: {:error, :invalid_argument}
end
