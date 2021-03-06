defmodule EkzerInterfaceWeb.Router do
  use EkzerInterfaceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EkzerInterfaceWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/add/new_exercise/type", PageController, :new
    post "/add/new_exercise/type", PageController, :new
    post "referentiel", PageController, :referentiel
    post "summary", ExerciseController, :summary
  end

  scope "/add/new_exercise", EkzerInterfaceWeb do
    pipe_through :browser

    get "/situation", ExerciseController, :exercise_type
    post "/situation", ExerciseController, :exercise_type
    post "/objectives", ExerciseController, :exercise_situation
    post "/keywords", ExerciseController, :exercise_objectives
    post "/consigne", ExerciseController, :exercise_keywords
    post "/specific_infos", ExerciseController, :exercise_consigne
    post "/validation_classer", ExerciseController, :validate_classer
    post "/validation_quizz", ExerciseController, :validate_quizz
    post "/validation_associer", ExerciseController, :validate_associer
    post "/validation_prelever", ExerciseController, :validate_prelever
    post "/validation_completer", ExerciseController, :validate_completer
  end

  scope "/add", EkzerInterfaceWeb do
    pipe_through :browser

    get "/error_basic_infos", ExerciseController, :error_basic_infos
    post "/specific_infos", ExerciseController, :specific_infos
    post "/validate_exercise", ExerciseController, :validate_exercise
  end
end
