{
  pkgs,
  userConfig,
  ...
}:
{
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
  ];

  # Networking / firewall
  networking.applicationFirewall.enable = true;
  networking.applicationFirewall.enableStealthMode = true;
  networking.applicationFirewall.allowSigned = true;
  networking.applicationFirewall.allowSignedApp = true;
  networking.computerName = "Blackbook";

  # Zsh
  programs.zsh.enable = true;

  # System settings
  system = {
    primaryUser = userConfig.name;
    defaults = {
      CustomUserPreferences = {
        # Disable siri
        "com.apple.Siri" = {
          "UAProfileCheckingStatus" = 0;
          "siriEnabled" = 0;
        };
        # Disable personalized ads
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
      };
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    source-code-pro
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # Homebrew (managed via nix-darwin)
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = false;
    onActivation.upgrade = true;

    casks = [
      "emacs-app"
      "firefox"
      "vscodium"
      # "vlc"  # temporarily disabled — cask download failing
    ];
  };
}
