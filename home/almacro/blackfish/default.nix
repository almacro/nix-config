{ pkgs, userConfig, nhModules, ... }:

{
  imports = [ 
    "${nhModules}/core" 
    "${nhModules}/groups/sway.nix" 
  ];

  home.username = userConfig.name;
  home.homeDirectory = "/home/${userConfig.name}";
  home.stateVersion = "26.05";   # set once; do not bump on upgrades
}
