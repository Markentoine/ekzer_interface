defmodule EkzerInterfaceWeb.ExerciseCommander do
  use Drab.Commander

  defhandler changed_nb_col(socket, sender) do
    nb_col = sender["value"]
    put_store(socket, :nb_col, nb_col)
  end

  defhandler create_cols(socket, sender) do
    nb_col = String.to_integer(get_store(socket, :nb_col))
    colonnes = Enum.map(1..nb_col, fn nb -> "colonne_#{nb}" end)
    Drab.Live.poke(socket, colonnes: colonnes)
  end

  defhandler changed_nb_answers(socket, sender) do
    nb_answers = sender["value"]
    put_store(socket, :nb_answers, nb_answers)
  end

  defhandler create_answers(socket, sender) do
    nb_answers = String.to_integer(get_store(socket, :nb_answers))
    answers = Enum.map(1..nb_answers, fn nb -> nb end)
    Drab.Live.poke(socket, answers: answers)
  end

  defhandler change_nb_prop(socket, sender) do
    nb_prop = sender["value"]
    put_store(socket, :nb_prop, nb_prop)
  end

  defhandler create_prop(socket, sender) do
    nb_prop = String.to_integer(get_store(socket, :nb_prop))
    props = Enum.map(1..nb_prop, fn nb -> nb end)
    Drab.Live.poke(socket, props: props)
  end

end
