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
    cond do 
      correct_basic_infos?(level, progression, field) ->
        {:ok, :success} = EkzerAdd.add_common_infos(exercise_pid, params)
        display_specific_infos(conn, type)
      true -> conn |> put_flash(:error, "Certaines informations sont erronées ou manquantes.") |> redirect(to: "/add/new_exercice/basic_infos")
    end
  end

  def error_basic_infos(conn, type) do
    render(conn, "new_exercice.html", type: type)
  end

  #PRIVATE

  defp display_specific_infos(conn, :classer = type) do
    render(conn, "classer_infos.html", %{type: type, colonnes: ["colonne 1", "colonne 2", "colonne 3"]})
  end
  defp display_specific_infos(conn, :quizz = type) do
    render(conn, "quizz_infos.html", %{type: type})
  end
  defp display_specific_infos(conn, :associer = type) do
    render(conn, "associer_infos.html", %{type: type})
  end
  defp display_specific_infos(conn, :prelever = type) do
    render(conn, "prelever_infos.html", %{type: type})
  end
  defp display_specific_infos(conn, :completer = type) do
    render(conn, "completer_infos.html", %{type: type})
  end

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