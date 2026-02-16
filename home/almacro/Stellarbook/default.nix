{ nhModules, ... }:
{
  imports = [
    "${nhModules}/common"
  ];

  # Tailscale
  home.sessionPath = [
    "/Applications/Tailscale.app/Contents/MacOS"
  ];

  programs.zsh.shellAliases = {
    tssh = "/Applications/Tailscale.app/Contents/MacOS/Tailscale ssh";
  };
}
