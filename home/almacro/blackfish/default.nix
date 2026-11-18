{ pkgs, userConfig, ... }:

{
  home.username = userConfig.name;
  home.homeDirectory = "/home/${userConfig.name}";
  home.stateVersion = "26.05";   # set once; do not bump on upgrades
}
