defmodule EkzerInterfaceWeb.PageController do
  use EkzerInterfaceWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :adder_pid) do
      nil -> 
        {:ok, adder_pid} = EkzerAdd.add()
        conn = put_session(conn, :adder_pid, adder_pid)
        render(conn, "index.html")
        _ -> 
        render(conn, "index.html")
    end
  end

  def new(conn, _params) do
    render(conn, "exercise_type.html")
  end
end
