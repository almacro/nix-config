{
  config,
  userConfig,
  lib,
  pkgs,
  ...
}:
let
  # RISC-V bare-metal cross toolchain. Expose the nix-native riscv64-none-elf-*
  # tools ALSO under the riscv64-unknown-elf-* names (the triple brew's
  # riscv64-elf-gcc uses) so scripts expecting either prefix just work.
  rvCrossGcc = pkgs.pkgsCross.riscv64-embedded.buildPackages.gcc;
  rvCrossBinutils = pkgs.pkgsCross.riscv64-embedded.buildPackages.binutils;
  riscv64UnknownElfAliases = pkgs.runCommand "riscv64-unknown-elf-aliases" { } ''
    mkdir -p $out/bin
    for d in ${rvCrossGcc}/bin ${rvCrossBinutils}/bin; do
      for src in "$d"/riscv64-none-elf-*; do
        [ -e "$src" ] || continue
        b=$(basename "$src")
        ln -sf "$src" "$out/bin/''${b/riscv64-none-elf/riscv64-unknown-elf}"
      done
    done
  '';
in
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
    mill

    # Go
    gopls

    # JavaScript / TypeScript
    nodejs
    bun
    deno
    pnpm
    typescript
    prettier
    eslint

    # Rust
    rustup

    # Python
    python314
    uv

    # OpenTofu (open-source Terraform fork)
    opentofu
    terragrunt

    # Lisp
    sbcl
    guile
    leiningen
    clojure
    clojure-lsp
    babashka
    racket

    # Protocol Buffers
    protobuf

    # RISC-V emulation + bare-metal cross toolchain
    qemu # includes qemu-system-riscv64
    rvCrossGcc # riscv64-none-elf-gcc
    rvCrossBinutils # riscv64-none-elf-{as,ld,objcopy,objdump,...}
    riscv64UnknownElfAliases # + riscv64-unknown-elf-* aliases

    # Search tools
    ripgrep
    fd

    # GitHub CLI
    gh

    # Graph visualization
    graphviz
    plantuml
    mermaid-cli

    # Command runner
    just
    parallel

    # Network tools
    wget
    lynx
    nmap

    # Database clients
    postgresql

    # Kubernetes
    kubectl
    kubernetes-helm
    minikube
    k9s
    argocd

    # PDF tools
    poppler-utils
    qpdf

    # Document conversion
    pandoc
    tectonic

    # Shell tooling
    shellcheck

    # Plotting
    gnuplot

    # Utilities
    watch
    htop
    tree
    yq-go
    yamllint
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

  # Environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    JAVA_HOME = "${pkgs.jdk21}";
    # Use the Nix-managed mmdc for the npm-installed mermaid-filter
    MERMAID_FILTER_CMD_MMDC = "${pkgs.mermaid-cli}/bin/mmdc";
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

  # Zsh extra init
  programs.zsh.initContent = ''
    [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
  '';

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
