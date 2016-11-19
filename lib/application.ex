defmodule TwilioBootstrap.Application do
  @moduledoc """
  Will create a Twilio application with the configured name if one does
  not already exist. If the Twilio application already exists, it will
  update the application settings to match the desired settings.
  """
  require Logger

  def start_link do
    Agent.start_link(fn -> bootstrap end, name: __MODULE__)
  end

  @doc """
  Fetches the Twilio application
  """
  @spec get :: %ExTwilio.Application{}
  def get do
    Agent.get(__MODULE__, fn application -> application end)
  end

  @spec bootstrap :: %ExTwilio.Application{}
  defp bootstrap do
    case find_or_create do
      {:ok, application} ->
        application
        |> announce
      {:error, message, code} ->
        raise "Unable to bootstrap Twilio application: #{message} #{code}"
    end
  end

  @spec announce(%ExTwilio.Application{}) :: %ExTwilio.Application{}
  defp announce(application) do
    Logger.info "ex_twilio_bootstrap: Boostrapped Twilio application \
'#{application.friendly_name}'\n\
\tSid: #{application.sid}\n\
\tVoice url: #{application.voice_url}\n\
\tSms url: #{application.sms_url}"
    application
  end

  @spec find_or_create :: {:ok, %ExTwilio.Application{}} | {:error, String.t, number}
  defp find_or_create do
    friendly_name = Application.get_env(:ex_twilio_bootstrap, :application_friendly_name)
    case find(friendly_name) do
      false ->
        ExTwilio.Application.create(settings_for_create(friendly_name))
      application ->
        ExTwilio.Application.update(application, settings_for_update)
    end
  end

  @spec find(String.t) :: %ExTwilio.Application{} | false
  defp find(friendly_name) do
    case ExTwilio.Application.all([{:friendly_name, friendly_name}]) do
      [] ->
        false
      [application | _] ->
        application
    end
  end

  @spec settings_for_create(String.t) :: map
  defp settings_for_create(friendly_name) do
    Map.put(settings_for_update, :friendly_name, friendly_name)
  end

  @spec settings_for_update :: map
  defp settings_for_update do
    %{
      voice_url: public_url <> "/voice",
      sms_url: public_url <> "/sms"
    }
  end

  @spec public_url :: String.t
  defp public_url do
    url = Application.get_env(:ex_twilio_bootstrap, :public_url)
    if is_function(url) do
      url.()
    else
      url
    end
  end
end
