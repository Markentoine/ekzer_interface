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
    
    post "/new_exercice/basic_infos", ExerciceController, :new_exercice
    post "/summary", ExerciceController, :summary
  end

  scope "/add/new_exercice", EkzerInterfaceWeb do
    pipe_through :browser

    post "/specific_infos", ExerciceController, :specific_infos
  end

end
