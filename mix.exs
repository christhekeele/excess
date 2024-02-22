defmodule Excess.Mix.Project do
  use Mix.Project

  @name "Excess"
  @description "An EliXir Entity-Component-System framework"
  @authors ["Chris Keele"]
  @maintainers ["Chris Keele"]
  @licenses ["MIT"]

  @release_branch "release"

  @github_url "https://github.com/christhekeele/excess"
  @homepage_url @github_url

  @dev_envs [:dev, :test]

  def project,
    do: [
      app: :excess,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]

  def application,
    do: [
      mod: {Excess.Application, []},
      extra_applications: [
        :logger
      ]
    ]

  defp deps,
    do: [
      {:uuid, "~> 1.1.0"},
      {:matcha, github: "christhekeele/matcha", ref: "73ae2d4"},
      # {:matcha, path: "~/Projects/oss/elixir/matcha"},
      {:ex_doc, "~> 0.27", only: @dev_envs, runtime: false}
    ]

  defp docs,
    do: [
      # Metadata
      name: @name,
      authors: @authors,
      source_ref: @release_branch,
      source_url: @github_url,
      homepage_url: @homepage_url,
      # Files and Layout
      extra_section: "OVERVIEW",
      main: "Excess",
      # logo: "docs/img/logo.png",
      # cover: "docs/img/cover.png",
      extras: [
        # Reference
        # "CHANGELOG.md": [filename: "changelog", title: "Changelog"],
        # "CONTRIBUTING.md": [filename: "contributing", title: "Contributing"],
        # "CONTRIBUTORS.md": [filename: "contributors", title: "Contributors"],
        # "LICENSE.md": [filename: "license", title: "License"]
      ],
      groups_for_extras: [
        Guides: ~r|docs/guides|,
        Cheatsheets: ~r|docs/cheatsheets|,
        Reference: [
          # "CHANGELOG.md",
          # "CONTRIBUTING.md",
          # "CONTRIBUTORS.md",
          # "LICENSE.md"
        ]
      ],
      groups_for_modules: [
        Runtime: [
          Excess.Runtime,
          Excess.Runtime.Access
        ],
        Events: [
          Excess.Event,
          Excess.Event.Hooks
        ],
        Entities: [
          Excess.Entity,
          Excess.Entity.Access
        ],
        Components: [
          Excess.Component,
          Excess.Component.Access
        ],
        Systems: [
          Excess.System
        ]
      ],
      nest_modules_by_prefix: []
    ]
end
