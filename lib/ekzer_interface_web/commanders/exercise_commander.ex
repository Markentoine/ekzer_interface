defmodule EkzerInterfaceWeb.ExerciseCommander do
  use Drab.Commander

  defhandler changed_nb_col(socket, sender) do
    nb_col = sender["value"]
    put_store(socket, :nb_col, nb_col)
  end

  defhandler changed_nb_questions(socket, sender) do
    nb_questions = sender["value"]
    put_store(socket, :nb_questions, nb_questions)
  end

  defhandler create_cols(socket, sender) do
    nb_col = String.to_integer(get_store(socket, :nb_col))
    colonnes = Enum.map(1..nb_col, fn nb -> "colonne_#{nb}" end)
    Drab.Live.poke(socket, colonnes: colonnes)
  end

  defhandler create_questions(socket, sender) do
    nb_questions = String.to_integer(get_store(socket, :nb_questions))
    questions = Enum.map(1..nb_questions, fn nb -> "question_#{nb}" end)
    Drab.Live.poke(socket, questions: questions)
  end

end
