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
    post "/add", PageController, :add
  end

  scope "/add", EkzerInterfaceWeb do
    pipe_through :browser

    get "/new_exercise/basic_infos", ExerciseController, :new_exercise
    post "/new_exercise/objectives", ExerciseController, :exercise_objectives
    post "/new_exercise/keywords", ExerciseController, :exercise_keywords
    post "/new_exercise/consigne", ExerciseController, :exercise_consigne
    post "/new_exercise/basic_infos", ExerciseController, :new_exercise
    post "/summary", ExerciseController, :summary
  end

  scope "/add/new_exercise", EkzerInterfaceWeb do
    pipe_through :browser

    get "/error_basic_infos", ExerciseController, :error_basic_infos
    post "/specific_infos", ExerciseController, :specific_infos
    post "/validate_exercise", ExerciseController, :validate_exercise
  end
end
