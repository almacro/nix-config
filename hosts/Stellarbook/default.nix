{ darwinModules, inputs, lib, ... }:
{
  imports = [
    "${darwinModules}/common"
  ];

  nixpkgs.overlays = [
    (final: prev:
      let
        previous = import inputs.nixpkgs-prev {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "surrealdb" ];
        };
      in {
        # keep the May builds, so the bump does not rebuild them on this Mac
        surrealdb = previous.surrealdb;
        grafana-loki = previous.grafana-loki;
      })
  ];

  # Standalone Tailscale.app (Developer ID build from tailscale.com). Adopt the
  # existing manual install once with: brew install --cask --adopt tailscale-app
  homebrew.casks = [
    "tailscale-app"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "graphite-cli"
    "graphite-cli-unwrapped"
    "surrealdb"
  ];
}
