{ darwinModules, lib, ... }:
{
  imports = [
    "${darwinModules}/common"
  ];

  # Standalone Tailscale.app (Developer ID build from tailscale.com). Adopt the
  # existing manual install once with: brew install --cask --adopt tailscale-app
  homebrew.casks = [
    "tailscale-app"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "graphite-cli"
    "surrealdb"
  ];
}
