{ ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = false;
    onActivation.upgrade = true;

    brews = [
      "python@3.14"
    ];

    casks = [
      "emacs-app"
      "firefox"
      "iterm2"
      "krita"
      "tigervnc"
      "vscodium"
      "vlc"
      "postico@1"
      "dbeaver-community"
    ];
  };
}
