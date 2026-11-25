{
  config,
  userConfig,
  lib,
  pkgs,
  ...
}:
{
  # Home-Manager configuration
  home = {
    username = userConfig.name;
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then
        "/Users/${userConfig.name}"
      else
        "/home/${userConfig.name}";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) "sd-switch";

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = userConfig.fullName;
      user.email = userConfig.email;
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };
    };
  };

  # Daily CLI essentials + Go tooling. Language toolchains and heavier tools
  # live in modules/home-manager/groups/* (imported on full hosts via common).
  home.packages = with pkgs; [
    # Go
    gopls

    # Search tools
    ripgrep
    fd

    # GitHub CLI
    gh

    # Command runner
    just
    parallel

    # Network tools
    wget
    lynx
    nmap

    # Shell / lint tooling
    shellcheck
    yamllint

    # Utilities
    watch
    htop
    tree
    yq-go
    restic
  ];

  # Go configuration
  programs.go = {
    enable = true;
    # Absolute path: Go's env file does NOT expand $HOME, so a literal
    # "$HOME/.go" would be stored verbatim and break every go command.
    env.GOPATH = "${config.home.homeDirectory}/.go";
  };

  # Session PATH
  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
  ];

  # Environment variables. Group-specific vars (JAVA_HOME, MERMAID_FILTER_...)
  # live in their respective group modules so they don't pull those store
  # paths into a core-only closure.
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      emacs = "/Applications/Emacs.app/Contents/MacOS/Emacs";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    plugins = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # Zsh extra init
    initContent =
      if pkgs.stdenv.hostPlatform.isLinux then ''
        if [[ $TERM == linux ]]; then
          # bare Linux console: no Nerd Font glyphs, so use a plain prompt
          PROMPT='%F{green}%n@%m%f %F{blue}%~%f %# '
        else
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
        fi
      '' else ''
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      '';

    # Login-shell setup (Homebrew + podman). Lands in the
    # home-manager-managed ~/.zprofile.
    profileExtra = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"
      export PATH=$PATH:/opt/podman/bin
    '';
  };

  # Delta (git pager)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Bat (better cat)
  programs.bat.enable = true;

  # Eza (better ls)
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  # Fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Powerlevel10k configuration
  home.file.".p10k.zsh".source = ./p10k.zsh;

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = lib.mkDefault "24.11";
}
