{ ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = false;
    onActivation.upgrade = true;

    # Python is provided by nix (pkgs.python314 in home-manager common) — the
    # Homebrew python@3.14 bottle linked against a system libexpat missing a
    # required symbol, breaking venv/ensurepip. cleanup = "zap" uninstalls it.
    brews = [ ];

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
