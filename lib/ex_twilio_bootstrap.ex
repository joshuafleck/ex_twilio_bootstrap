defmodule TwilioBootstrap do
  @moduledoc """
  Ensures that a Twilio application and telephone number exist
  and are configured. Exposes the application and telephone
  number settings to your application.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(TwilioBootstrap.Application, []),
      worker(TwilioBootstrap.TelephoneNumber, []),
    ]

    opts = [strategy: :rest_for_one, name: TwilioBootstrap.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
