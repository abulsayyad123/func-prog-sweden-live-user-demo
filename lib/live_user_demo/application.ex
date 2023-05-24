defmodule LiveUserDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveUserDemoWeb.Telemetry,
      # Start the Ecto repository
      LiveUserDemo.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveUserDemo.PubSub},
      # Start Finch
      {Finch, name: LiveUserDemo.Finch},
      # Start the Endpoint (http/https)
      LiveUserDemoWeb.Endpoint,
      # Start a worker by calling: LiveUserDemo.Worker.start_link(arg)
      # {LiveUserDemo.Worker, arg}
      LiveUserDemoWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveUserDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveUserDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
