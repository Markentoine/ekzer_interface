defmodule EkzerInterface.Application do
  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      EkzerInterfaceWeb.Endpoint
      # Starts a worker by calling: EkzerInterface.Worker.start_link(arg)
      # {EkzerInterface.Worker, arg},
    ]

    opts = [strategy: :one_for_one, name: EkzerInterface.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EkzerInterfaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
