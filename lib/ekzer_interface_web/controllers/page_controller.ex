defmodule EkzerInterfaceWeb.PageController do
  use EkzerInterfaceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def add(conn, _params) do
    {:ok, adder_pid} = EkzerAdd.add()
    conn = put_session(conn, :adder_pid, adder_pid)
    render(conn, "add.html")
  end
end
