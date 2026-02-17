{ ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = false;
    onActivation.upgrade = true;

    casks = [
      "emacs-app"
      "firefox"
      "tigervnc"
      "vscodium"
      "vlc"
    ];
  };
}
