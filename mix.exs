defmodule TwilioBootstrap.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_twilio_bootstrap,
     version: "0.1.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     description: description(),
     dialyzer: [plt_add_deps: :transitive]]
  end

  def application do
    [applications: [:logger, :ex_twilio],
     env: [
      application_friendly_name: "ex_twilio_bootstrap",
      telephone_number_friendly_name: "ex_twilio_bootstrap",
      public_url: "http://test.org",
      iso_country_code: "GB"
     ],
     mod: {TwilioBootstrap, []}]
  end

  defp deps do
    [{:ex_twilio, "~> 0.2"},
     {:ex_doc, "~> 0.14", only: :dev},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:dialyxir, "~> 0.4", only: [:dev]}]
  end

  defp description do
    """
    Bootstraps a Twilio application and telephone number upon startup
    to ease development of TwiML applications
    """
  end

  defp package do
    [maintainers: ["Joshua Fleck"],
     files: ["lib", "mix.exs", "README.md", "LICENSE"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/joshuafleck/ex_twilio_bootstrap"}]
  end
end
