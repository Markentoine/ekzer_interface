defmodule EkzerInterfaceWeb.ExerciseController do
  use EkzerInterfaceWeb, :controller

  def exercise_type(conn, %{"type" => type}) do
    {:ok, exercise_pid} = EkzerAdd.new_exercise(String.to_atom(type))
    new_conn = put_session(conn, :current_exercise, exercise_pid)
    adder_pid = get_session(new_conn, :adder_pid)
    EkzerAdd.register_exercise(adder_pid, exercise_pid)
    render(new_conn, "exercise_situation.html", type: type)
  end

  def exercise_type(conn, %{}) do
    {:ok, type} = EkzerAdd.get_exercise_value(get_session(conn, :current_exercise), :type)
    render(conn, "exercise_situation.html", type: type)
  end

  def exercise_situation(conn, %{ "level" => level, "progression" => progression, "field" => field}) do
    cond do
      correct_basic_infos?(level, progression, field) ->
        conn
        |> register_infos(%{ "level" => String.to_integer(level),
                            "progression" => String.to_integer(progression),
                            "field" => field,
                          })
        |> render("objectives.html")
        true ->
          conn
          |> put_flash(:error, "Certaines informations sont erronées ou manquantes.")
          |> redirect(to: "/add/new_exercise/situation")
    end
  end
      
  def exercise_objectives(conn, %{"objectives" => objectives}) do
    conn
    |> register_infos(%{ "objectives" => [objectives]})
    |> render("keywords.html")
  end

  def exercise_keywords(conn, %{"keywords" => keywords}) do
    conn
    |> register_infos(%{ "keywords" => String.split(keywords)})
    |> render("consigne.html")
  end

  def exercise_consigne(conn, %{"consigne" => consigne} = _params) do
    conn
    |> register_infos(%{ "consigne" => consigne})
    |> specific_infos(_params)
  end

  def specific_infos(conn, _params) do
    exercise_pid = get_session(conn, :current_exercise)
    {:ok, type} = EkzerAdd.get_exercise_value(exercise_pid, :type)
    display_specific_infos(conn, type)
  end

  def summary(conn, _params) do
    _pids =
      get_session(conn, :adder_pid)
      |> EkzerAdd.fetch_exercises_pids()

    render(conn, "summary.html")
  end

  def validate_classer(conn, params) do
    exercise_pid = get_session(conn, :current_exercise)
    {:ok, type} = EkzerAdd.get_exercise_value(exercise_pid, :type)

    cols =
      Enum.filter(Map.keys(params), fn p -> Regex.match?(~r/colonne/, p) end)
      |> Enum.reduce(%{}, fn col, acc -> Map.put(acc, col, String.split(params[col])) end)

    {:ok, :success} = EkzerAdd.add_specific_infos(exercise_pid, type, cols)
    {:ok, exercise} = EkzerAdd.get_state(exercise_pid)
    render(conn, "validate_exercise.html", exercise: exercise)
  end
  
  def validate_quizz(conn, _params ) do
    render(conn, "validate_exercise.html", exercise: %{})
  end

  def error_basic_infos(conn, type) do
    render(conn, "new_exercice.html", type: type)
  end

  # PRIVATE

  defp display_specific_infos(conn, :classer = type) do
    render(conn, "classer_infos.html", %{
      type: type,
      colonnes: ["colonne_1", "colonne_2", "colonne_3"]
    })
  end

  defp display_specific_infos(conn, :quizz = type) do
    render(conn, "quizz_infos.html", %{
      type: type,
      questions: ["question_1", "question_2", "question_3"]
      })
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

  defp field_in_list(field) do
    field in ["grammaire", "vocabulaire", "orthographe", "conjugaison"]
  end

  defp is_number?(v) do
    Regex.match?(~r/\d+/, v)
  end

  defp register_infos(conn, infos) do
    exercise_pid = get_session(conn, :current_exercise)
    {:ok, :success} = EkzerAdd.add_common_infos(exercise_pid, infos)
    conn
  end

end
