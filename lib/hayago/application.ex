defmodule Hayago.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      HayagoWeb.Endpoint,
      {Registry, keys: :unique, name: Hayago.GameRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Hayago.GameSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Hayago.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HayagoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
