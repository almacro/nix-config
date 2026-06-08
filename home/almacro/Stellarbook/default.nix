{ nhModules, pkgs, ... }:
{
  imports = [
    "${nhModules}/common"
  ];

  # Secrets management
  home.packages = with pkgs; [
    doppler
    graphite-cli
    codespell
    flyctl
    biome

    # Databases
    surrealdb
    goose
  ];

  # Tailscale
  home.sessionPath = [
    "/Applications/Tailscale.app/Contents/MacOS"
  ];

  programs.zsh.shellAliases = {
    tssh = "/Applications/Tailscale.app/Contents/MacOS/Tailscale ssh";
  };
}
