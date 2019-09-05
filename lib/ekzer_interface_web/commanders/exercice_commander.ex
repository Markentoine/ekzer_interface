defmodule EkzerInterfaceWeb.ExerciceCommander do
  use Drab.Commander
  # Place your event handlers here
  #
  # defhandler button_clicked(socket, sender) do
  #   set_prop socket, "#output_div", innerHTML: "Clicked the button!"
  # end
  #
  # Place you callbacks here
  #
  # onload :page_loaded
  #
  # def page_loaded(socket) do
  #   set_prop socket, "div.jumbotron h2", innerText: "This page has been drabbed"
  # end
  defhandler changed_nb_col(socket, sender) do
    nb_col = sender["value"]
    put_store(socket, :nb_col, nb_col)
  end

  defhandler create_cols(socket, sender) do
    nb_col = String.to_integer(get_store(socket, :nb_col))
    colonnes = Enum.map(1..nb_col, fn nb -> "colonne #{nb}" end)
    Drab.Live.poke socket, colonnes: colonnes
  end
end
