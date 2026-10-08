{ nhModules, pkgs, ... }:
{
  imports = [
    "${nhModules}/common"
  ];

  # Secrets management
  home.packages = with pkgs; [
    doppler
    graphite-cli
    codespell
    flyctl
    biome
    spacectl
    golangci-lint
    natscli
    sccache
    actionlint

    # Databases
    surrealdb
    goose
  ];

  # sccache: Rust/C compiler cache. Unlike target/ (unbounded), its cache is
  # size-capped with LRU eviction, so it won't balloon the disk.
  home.sessionVariables = {
    RUSTC_WRAPPER = "sccache";
    SCCACHE_CACHE_SIZE = "20G";
    # sccache cannot cache incremental builds; disable incremental so cargo
    # actually routes compiles through sccache (also curbs target/ growth).
    CARGO_INCREMENTAL = "0";
  };

  # Tailscale
  home.sessionPath = [
    "/Applications/Tailscale.app/Contents/MacOS"
  ];

  programs.zsh.shellAliases = {
    tssh = "/Applications/Tailscale.app/Contents/MacOS/Tailscale ssh";
  };
}
