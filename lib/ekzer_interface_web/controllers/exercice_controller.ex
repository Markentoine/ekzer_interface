defmodule EkzerInterfaceWeb.ExerciceController do
  use EkzerInterfaceWeb, :controller

  def new_exercice(conn, %{"exercice" => %{"type" => type}}) do
    {:ok, exercise_pid} = EkzerAdd.new_exercise(String.to_atom(type))
    conn = put_session(conn, :current_exercise, exercise_pid)
    adder_pid = get_session(conn, :adder_pid)
    EkzerAdd.register_exercise(adder_pid, exercise_pid)
    {:ok, exercise_entries} = EkzerAdd.fetch_entries(exercise_pid)
    render(conn, "new_exercice.html", %{type: type, entries: exercise_entries})
  end

  def summary(conn, _params) do
    pids = get_session(conn, :adder_pid)
    |> EkzerAdd.fetch_exercises_pids()
    render(conn, "summary.html")
  end

  def basic_infos(conn, %{"level" => level, "progression" => progression, "field" => field, "consigne" => consigne}) do
    {:ok, type} = EkzerAdd.get_exercise_value(get_session(conn, :current_exercise), :type)
    cond do 
      correct_basic_infos?(level, progression, field) -> render(conn, "specific_infos.html")
      true -> render(conn, "new_exercice.html", type: type)
    end
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