{
  pkgs,
  userConfig,
  hostname,
  ...
}:
{
  imports = [
    ./system-defaults.nix
    ./homebrew.nix
  ];

  # Determinate Nix manages nix itself; disable nix-darwin's nix management
  nix.enable = false;

  # User configuration
  users.users.${userConfig.name} = {
    name = userConfig.name;
    home = "/Users/${userConfig.name}";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    mg
    tmux
    vim
    krunkit
  ];

  # Networking / firewall
  networking.applicationFirewall.enable = true;
  networking.applicationFirewall.enableStealthMode = true;
  networking.applicationFirewall.allowSigned = true;
  networking.applicationFirewall.allowSignedApp = true;
  networking.computerName = hostname;

  # Zsh
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPath = [ "/etc/profiles/per-user/${userConfig.name}/bin" ];

  # System
  system.primaryUser = userConfig.name;

  # Fonts
  fonts.packages = with pkgs; [
    meslo-lgs-nf
    source-code-pro
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
}
