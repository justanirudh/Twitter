defmodule TwitterClient.Mixfile do
  use Mix.Project

  def project do
    [
      app: :project4_client,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [cookie: :monster]
    ]
  end

  #Run as an executable
  def escript do
    [main_module: TwitterClient,
    emu_args: [ "+P 5000000" ]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
