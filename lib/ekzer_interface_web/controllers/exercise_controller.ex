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

  def exercise_situation(conn, %{"level" => level, "progression" => progression, "field" => field}) do
    cond do
      correct_basic_infos?(level, progression, field) ->
        conn
        |> register_infos(%{
          "level" => String.to_integer(level),
          "progression" => String.to_integer(progression),
          "field" => field
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
    |> register_infos(%{"objectives" => [objectives]})
    |> render("keywords.html")
  end

  def exercise_keywords(conn, %{"keywords" => keywords}) do
    conn
    |> register_infos(%{"keywords" => String.split(keywords)})
    |> render("consigne.html")
  end

  def exercise_consigne(conn, %{"consigne" => consigne} = _params) do
    conn
    |> register_infos(%{"consigne" => consigne})
    |> specific_infos(_params)
  end

  def specific_infos(conn, _params) do
    {:ok, type} = EkzerAdd.get_exercise_value(get_pid(conn), :type)
    display_specific_infos(conn, type)
  end

  def summary(conn, _params) do
    pids =
      conn
      |> get_session(:adder_pid)
      |> IO.inspect()
      |> EkzerAdd.fetch_exercises_pids()

    IO.inspect(pids)

    states =
      Enum.map(pids, fn pid ->
        {:ok, state} = EkzerAdd.get_state(pid)
        state
      end)

    IO.inspect(states)
    render(conn, "summary.html", states: states)
  end

  def validate_classer(conn, params) do
    exercise_pid = get_pid(conn)

    cols =
      Map.keys(params)
      |> Enum.filter(fn p -> Regex.match?(~r/colonne/, p) end)
      |> Enum.reduce(%{}, fn col, acc ->
        Map.put(acc, col, String.split(params[col]))
      end)

    {:ok, :success} = EkzerAdd.add_specific_infos(exercise_pid, :classer, cols)
    {:ok, exercise} = EkzerAdd.get_state(exercise_pid)
    render(conn, "validate_exercise.html", exercise: exercise)
  end

  def validate_quizz(conn, params) do
    register_question_quizz(conn, params)
    display_specific_infos(conn, :quizz)
  end

  def validate_associer(conn, params) do
    exercise_pid = get_pid(conn)
    nb_prop = String.to_integer(params["nb_prop"])

    propositions =
      Enum.map(1..nb_prop, & &1)
      |> Enum.map(
        &%{proposition: params["proposition_#{&1}"], predicat: params["predicat_#{&1}"]}
      )

    {:ok, :success} = EkzerAdd.add_specific_infos(exercise_pid, :associer, propositions)
    {:ok, exercise} = EkzerAdd.get_state(exercise_pid)
    render(conn, "validate_exercise.html", exercise: exercise)
  end
  
  def validate_prelever(conn, params) do
    exercise_pid = get_pid(conn)
    text = params["text"]
    prelevements = params["prelevements"] |> String.split("/")
    infos = %{texte: text, prelevements: prelevements}
    {:ok, :success} = EkzerAdd.add_specific_infos(exercise_pid, :prelever, infos)
    {:ok, exercise} = EkzerAdd.get_state(exercise_pid)
    IO.inspect exercise
    render(conn, "validate_exercise.html", exercise: exercise)
  end

  def validate_exercise(conn, params) do
    {:ok, exercise} = conn 
                      |> get_pid 
                      |> EkzerAdd.get_state()
    IO.inspect(exercise)
    render(conn, "validate_exercise.html", exercise: exercise)
  end

  def error_basic_infos(conn, type) do
    render(conn, "new_exercice.html", type: type)
  end

  # PRIVATE
  defp get_pid(conn), do: get_session(conn, :current_exercise)

  defp register_question_quizz(conn, params) do
    exercise_pid = get_session(conn, :current_exercise)
    params_keys = Map.keys(params)
    question_nb = find_question_nb(params_keys)
    question = params[find_question_key(params_keys)]
    answers = get_answers(params_keys, params)
    quizz_entry = %{question: question, nb: question_nb, answers: answers}
    {:ok, :success} = EkzerAdd.add_specific_infos(exercise_pid, :quizz, quizz_entry)
  end

  defp display_specific_infos(conn, :classer = type) do
    render(conn, "classer_infos.html", %{
      type: type,
      colonnes: ["colonne_1", "colonne_2", "colonne_3"]
    })
  end

  defp display_specific_infos(conn, :quizz = type) do
    exercise_pid = get_session(conn, :current_exercise)
    {:ok, questions} = EkzerAdd.get_exercise_value(exercise_pid, :specific_fields)
    question_nb = Enum.count(questions.questions) + 1

    render(conn, "quizz_infos.html", %{
      type: type,
      question_nb: question_nb,
      answers: []
    })
  end

  defp display_specific_infos(conn, :associer = type) do
    render(conn, "associer_infos.html", %{type: type, props: []})
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

  defp find_question_key(keys) do
    keys
    |> Enum.filter(fn p -> Regex.match?(~r/question/, p) end)
    |> hd
  end

  defp find_question_nb(keys) do
    keys
    |> Enum.filter(fn p -> Regex.match?(~r/question/, p) end)
    |> hd
    |> String.split("_")
    |> tl
    |> hd
    |> String.to_integer()
  end

  def get_answers(keys, params) do
    keys
    |> Enum.filter(fn p -> Regex.match?(~r/answer_/, p) end)
    |> Enum.map(fn ans ->
      nb = String.split(ans, "_") |> Enum.reverse() |> hd
      %{answer: params[ans], correct: params["correct_#{nb}"] |> String.to_atom()}
    end)
  end

  defp is_number?(v) do
    Regex.match?(~r/\d+/, v)
  end

  defp register_infos(conn, infos) do
    {:ok, :success} = EkzerAdd.add_common_infos(get_pid(conn), infos)
    conn
  end
end
