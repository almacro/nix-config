{ nhModules, pkgs, ... }:
{
  imports = [
    "${nhModules}/common"
  ];

  # WireGuard
  home.packages = [ pkgs.wireguard-tools ];
}
