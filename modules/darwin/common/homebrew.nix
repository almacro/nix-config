{ ... }:
{
  homebrew = {
    enable = true;
    # "none" (not "zap"): the pinned nix-darwin passes the bare `brew bundle
    # --cleanup` flag for zap/uninstall, which Homebrew 7 disabled. "none"
    # avoids that call. Trade-off: removing a brew/cask here no longer auto-
    # uninstalls it (do `brew uninstall` by hand). Revisit when nixpkgs+darwin
    # are bumped together (newer nix-darwin uses `brew bundle cleanup`).
    onActivation.cleanup = "none";
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
