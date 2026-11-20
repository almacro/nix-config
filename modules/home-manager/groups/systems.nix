{ pkgs, ... }:
let
  # RISC-V bare-metal cross toolchain. Expose the nix-native riscv64-none-elf-*
  # tools ALSO under the riscv64-unknown-elf-* names (brew's triple) so scripts
  # expecting either prefix just work. Bin-only (no share/info) — avoids the
  # install-info "START-INFO-DIR-ENTRY" failure the raw packages' info docs
  # trigger when merged into the user environment.
  rvCrossGcc = pkgs.pkgsCross.riscv64-embedded.buildPackages.gcc;
  rvCrossBinutils = pkgs.pkgsCross.riscv64-embedded.buildPackages.binutils;
  riscv64ElfToolchain = pkgs.runCommand "riscv64-elf-toolchain" { } ''
    mkdir -p $out/bin
    for d in ${rvCrossGcc}/bin ${rvCrossBinutils}/bin; do
      for src in "$d"/riscv64-none-elf-*; do
        [ -e "$src" ] || continue
        b=$(basename "$src")
        ln -sf "$src" "$out/bin/$b"
        ln -sf "$src" "$out/bin/''${b/riscv64-none-elf/riscv64-unknown-elf}"
      done
    done
  '';
in
{
  home.packages = with pkgs; [
    qemu # includes qemu-system-riscv64
    gcc
    riscv64ElfToolchain # riscv64-none-elf-* AND riscv64-unknown-elf-*
  ];
}
