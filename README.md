# ex_twilio_bootstrap

Bootstraps a Twilio application and telephone number upon startup to ease development of TwiML applications

## Installation

Add ex_twilio_bootstrap to your `mix.exs` dependencies...

from Hex:

```elixir
def deps do
  [{:ex_twilio_bootstrap, "0.1.0"}]
end
```

or, from Github:


```elixir
def deps do
  [{:ex_twilio_bootstrap, github: "joshuafleck/ex_twilio_bootstrap"}]
end
```

Include :ex_twilio_bootstrap as an application dependency:

```elixir
def application do
  [applications: [:ex_twilio_bootstrap]]
end
```

## Configuration

1. Ensure you've configured [ex_twilio](https://github.com/danielberkompas/ex_twilio#configuration) to use your Twilio account credentials.
1. The default configurations may be overridden by setting any of the following in your `config/config.exs` file:

```elixir
config :ex_twilio_bootstrap,
  # The public URL of your server (definitely override this)
  public_url: "http://test.org"
  # The friendly name of the Twilio application
  application_friendly_name: "ex_twilio_bootstrap",
  # The friendly name of the Twilio telephone number
  telephone_number_friendly_name: "ex_twilio_bootstrap",
  # The iso (2-char) country code to which your telephone number will be local
  iso_country_code: "GB"
```

## Usage

When you application is started, ex_twilio_bootstrap will log into your Twilio
account and check the following:

1. Do you have an programmable voice application named per the configured `application_friendly_name`?
  - If yes, set its `/voice` and `/sms` URLs to use the configured `public_url` respectively
  - If no, creates a programmable voice application setting its URLs as described above
1. Do you have a phone number named per the `telephone_number_friendly_name`?
  - If yes, set its voice and messaging URLs to point to those of the application described in the previous step
  - If no, purchases a local telephone number in the country of the configured `iso_country_code` setting its URLs as described above **Note: this will charge your Twilio account**

Your application may access the application or telephone number settings via the following

```elixir
# Fetches the application's settings
TwilioBootstrap.Application.get # => %ExTwilio.Application{account_sid: "...
# Fetches the telephone number's settings
TwilioBootstrap.TelephoneNumber.get # => %ExTwilio.IncomingPhoneNumber{account_sid: "...
```

Making a call or sms to your new telephone number will result in Twilio making a callback request to your application for TwiML on the following URLs:

- **Call** `{public_url}/voice`
- **SMS** `{public_url}/sms`

### Exposing your bootstrapped application to the web

[ex_ngrok](https://github.com/joshuafleck/ex_ngrok) provides a means for opening up your local Twilio application to the web, including allowing Twilio callbacks to be tunnelled to your local server. You can use ex_twilio_bootstrap with ex_ngrok to immediately begin testing a TwiML application with live calls by doing the following:

1. Add [ex_ngrok](https://github.com/joshuafleck/ex_ngrok#dependencies) to your application
1. Add [ex_twilio_bootstrap](#Installation) to your application
1. In your application's `config/config.exs` file, dynamically set the `public_url` by fetching it from ex_ngrok:

```elixir
config :ex_twilio_bootstrap,
  public_url: fn -> Ngrok.public_url end
```

Your programmable voice application will now be updated to use the url of the Ngrok tunnel created by ex_ngrok every time your application is started.
