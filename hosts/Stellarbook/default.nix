{ darwinModules, lib, ... }:
{
  imports = [
    "${darwinModules}/common"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "graphite-cli"
  ];
}
