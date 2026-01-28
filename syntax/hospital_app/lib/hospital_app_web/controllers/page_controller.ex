defmodule HospitalAppWeb.PageController do
  use HospitalAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
