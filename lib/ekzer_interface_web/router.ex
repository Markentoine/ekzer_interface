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
    post "/add/new_exercise/type", PageController, :add
  end

  scope "/add/new_exercise", EkzerInterfaceWeb do
    pipe_through :browser

    post "/situation", ExerciseController, :exercise_type
    post "/objectives", ExerciseController, :exercise_situation
    post "/keywords", ExerciseController, :exercise_objectives
    post "/consigne", ExerciseController, :exercise_keywords
    post "/specific_infos", ExerciseController, :exercise_consigne
    post "/validation", ExerciceController, :validate_exercise

  end

  scope "/add", EkzerInterfaceWeb do
    pipe_through :browser

    get "/error_basic_infos", ExerciseController, :error_basic_infos
    post "/summary", ExerciseController, :summary
    post "/specific_infos", ExerciseController, :specific_infos
    post "/validate_exercise", ExerciseController, :validate_exercise
  end
end
