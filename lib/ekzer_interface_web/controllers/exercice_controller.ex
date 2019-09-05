defmodule EkzerInterfaceWeb.ExerciceController do
  use EkzerInterfaceWeb, :controller

  def new_exercice(conn, %{"exercice" => %{"type" => type}}) do
    {:ok, exercise_pid} = EkzerAdd.new_exercise(String.to_atom(type))
    conn = put_session(conn, :current_exercise, exercise_pid)
    adder_pid = get_session(conn, :adder_pid)
    EkzerAdd.register_exercise(adder_pid, exercise_pid)
    render(conn, "new_exercice.html", type: type)
  end
  
  def new_exercice(conn, %{}) do
    {:ok, type} = EkzerAdd.get_exercise_value(get_session(conn, :current_exercise), :type)
    render(conn, "new_exercice.html", type: type)
  end

  def summary(conn, _params) do
    pids = get_session(conn, :adder_pid)
    |> EkzerAdd.fetch_exercises_pids()
    render(conn, "summary.html")
  end

  def specific_infos(conn, %{"level" => level, "progression" => progression, "field" => field, "consigne" => consigne} = params) do
    exercise_pid = get_session(conn, :current_exercise)
    {:ok, type} = EkzerAdd.get_exercise_value(exercise_pid, :type)
    {:ok, :success} =EkzerAdd.add_common_infos(exercise_pid, params)
    EkzerAdd.add_common_infos(exercise_pid, params)
    cond do 
      correct_basic_infos?(level, progression, field) -> render(conn, "specific_infos.html", type: type)
      true -> conn |> put_flash(:error, "Certaines informations sont erronées ou manquantes.") |> redirect(to: "/add/new_exercice/basic_infos")
    end
  end

  def error_basic_infos(conn, type) do
    render(conn, "new_exercice.html", type: type)
  end

  #PRIVATE

  defp correct_basic_infos?(level, progression, field) do
    is_number?(level) and is_number?(progression) and field_in_list(field)
  end

  defp is_number?(v) do
    Regex.match?(~r/\d+/, v)
  end

  defp field_in_list(field) do
    field in ["grammaire", "vocabulaire", "orthographe", "conjugaison"]
  end
end