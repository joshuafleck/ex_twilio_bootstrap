defmodule TwilioBootstrap.TelephoneNumber do
  @moduledoc """
  Will purchase a Twilio telephone number with the configured name if one does
  not already exist. If the Twilio telephone number already exists, it will
  update its settings to match the desired settings.
  """
  require Logger

  def start_link do
    Agent.start_link(fn -> bootstrap() end, name: __MODULE__)
  end

  @doc """
  Fetches the Twilio telephone number
  """
  @spec get :: %ExTwilio.IncomingPhoneNumber{}
  def get do
    Agent.get(__MODULE__, fn telephone_number -> telephone_number end)
  end

  @spec bootstrap :: %ExTwilio.IncomingPhoneNumber{}
  defp bootstrap do
    case find_or_create() do
      {:ok, telephone_number} ->
        telephone_number
        |> announce
      {:error, message, code} ->
        raise "Unable to bootstrap Twilio telephone number: #{message} #{code}"
    end
  end

  @spec announce(%ExTwilio.IncomingPhoneNumber{}) :: %ExTwilio.IncomingPhoneNumber{}
  defp announce(telephone_number) do
    Logger.info "ex_twilio_bootstrap: Boostrapped Twilio telephone number \
'#{telephone_number.friendly_name}'\n\
\tSid: #{telephone_number.sid}\n\
\tPhone number: #{telephone_number.phone_number}"
    telephone_number
  end

  @spec find_or_create :: {:ok, %ExTwilio.IncomingPhoneNumber{}} | {:error, String.t, number}
  defp find_or_create do
    friendly_name = Application.get_env(:ex_twilio_bootstrap, :telephone_number_friendly_name)
    application_sid = TwilioBootstrap.Application.get.sid
    case find(friendly_name) do
      false ->
        create(friendly_name, application_sid)
      telephone_number ->
        ExTwilio.IncomingPhoneNumber.update(telephone_number, settings_for_update(application_sid))
    end
  end

  defp create(friendly_name, application_sid) do
    available_phone_numbers = ExTwilio.AvailablePhoneNumber.stream(
      iso_country_code: Application.get_env(:ex_twilio_bootstrap, :iso_country_code),
      type: "Local",
      voice_enabled: true,
      sms_enabled: true)

    available_phone_numbers
    |> Enum.take(1)
    |> List.first
    |> settings_for_create(friendly_name, application_sid)
    |> ExTwilio.IncomingPhoneNumber.create
  end

  @spec find(String.t) :: %ExTwilio.IncomingPhoneNumber{} | false
  defp find(friendly_name) do
    case ExTwilio.IncomingPhoneNumber.all([{:friendly_name, friendly_name}]) do
      [] ->
        false
      [telephone_number | _] ->
        telephone_number
    end
  end

  @spec settings_for_create(%ExTwilio.AvailablePhoneNumber{}, String.t, String.t) :: map
  defp settings_for_create(available_phone_number, friendly_name, application_sid) do
    settings = %{
      friendly_name: friendly_name,
      phone_number: available_phone_number.phone_number
    }
    Map.merge(settings_for_update(application_sid), settings)
  end

  @spec settings_for_update(String.t) :: map
  defp settings_for_update(application_sid) do
    %{
      voice_application_sid: application_sid,
      sms_application_sid: application_sid
    }
  end
end
