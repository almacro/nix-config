{ ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = false;
    onActivation.upgrade = true;

    brews = [
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
