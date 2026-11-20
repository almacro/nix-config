{ pkgs, ... }:
{
  # rustup manages the toolchains imperatively under ~/.rustup; nix provides
  # only the installer (see also sccache wiring in the host configs).
  home.packages = with pkgs; [
    rustup
  ];
}
