{
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

  # Development toolchains
  home.packages = with pkgs; [
    # Java
    jdk21
    maven
    gradle

    # Go
    gopls

    # Rust
    rustup

    # OpenTofu (open-source Terraform fork)
    opentofu
    terragrunt

    # Lisp
    sbcl
    guile

    # Search tools
    ripgrep
    fd

    # GitHub CLI
    gh

    # Graph visualization
    graphviz
    plantuml

    # Command runner
    just

    # Network tools
    wget

    # Database clients
    postgresql

    # Kubernetes
    kubectl
    kubernetes-helm
  ];

  # Go configuration
  programs.go = {
    enable = true;
    env.GOPATH = "$HOME/.go";
  };

  # Session PATH
  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.cargo/bin"
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    JAVA_HOME = "${pkgs.jdk21}";
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

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
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

  # Zsh extra init
  programs.zsh.initContent = ''
    [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

    if [ -f "$HOME/.zprofile" ]; then
      source "$HOME/.zprofile"
    fi
  '';

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
