{ ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = false;
    onActivation.upgrade = true;

    brews = [
      "podman"
      "vfkit"
    ];

    casks = [
      "emacs-app"
      "firefox"
      "tigervnc"
      "vscodium"
      "vlc"
    ];
  };
}
