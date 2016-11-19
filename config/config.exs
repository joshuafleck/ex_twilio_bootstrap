use Mix.Config

config :ex_twilio,
  account_sid: System.get_env("TWILIO_ACCOUNT_SID") || "${TWILIO_ACCOUNT_SID}",
  auth_token:  System.get_env("TWILIO_AUTH_TOKEN") || "${TWILIO_AUTH_TOKEN}"

config :ex_twilio_bootstrap,
  # The friendly name of the Twilio application
  application_friendly_name: "ex_twilio_bootstrap",
  # The friendly name of the Twilio telephone number
  telephone_number_friendly_name: "ex_twilio_bootstrap",
  # The public URL of your server
  public_url: "http://test.org"
