defmodule EkzerInterfaceWeb.PageController do
  use EkzerInterfaceWeb, :controller

  def index(conn, _params) do
    case adder_alive?(conn) do
      false ->
        {:ok, adder_pid} = EkzerAdd.add()
        conn = put_session(conn, :adder_pid, adder_pid)
        render(conn, "index.html")

      true ->
        render(conn, "index.html")
    end
  end

  def new(conn, _params) do
    render(conn, "exercise_type.html")
  end

  # PRIVATE

  defp adder_alive?(conn) do
    conn
    |> get_session(:adder_pid)
    |> Process.alive?()
  end
end
