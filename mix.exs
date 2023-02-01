defmodule FT.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :ft,
      version: "3.1.0",
      elixir: "~> 1.7",
      description: "FT FormalTalk ERP.UNO Compiler",
      package: package(),
      deps: deps()
    ]
  end

  def package do
    [
      files: ~w(doc lib priv src mix.exs LICENSE),
      licenses: ["ISC"],
      maintainers: ["Namdak Tonpa"],
      name: :ft,
      links: %{"GitHub" => "https://github.com/erpuno/formaltalk"}
    ]
  end

  def application() do
    [mod: {:ft, []}]
  end

  def deps() do
    [
      {:schema, "~> 4.1.1"},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end
end
