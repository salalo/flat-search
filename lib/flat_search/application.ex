defmodule FlatSearch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the Ecto repository
      FlatSearch.Repo,
      # Start the Telemetry supervisor
      FlatSearchWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FlatSearch.PubSub},
      # Start the Endpoint (http/https)
      FlatSearchWeb.Endpoint,
      # Start a worker by calling: FlatSearch.Worker.start_link(arg)
      # {FlatSearch.Worker, arg}
      FlatSearch.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlatSearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FlatSearchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
