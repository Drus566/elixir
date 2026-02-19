defmodule Geometry do
  def rectangle_area(a, b) do
    a * b
  end

  def square_area(a) do
    rectangle_area(a, a)
  end
end

defmodule MyModule do
  alias IO, as: MyIO

  def my_function do
    MyIO.puts("Calling imported function")
  end

  def fun(a, b \\ 1, c, d \\ 2) do
    a + b + c + d
  end
end

defmodule Circle do
  # Аттрибут модуля, существует только во время компиляции модуля
  @pi 3.14159

  def area(r), do: r * r * @pi
  def circumference(r), do: 2 * r * @pi
end
