{ inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # plantuml 1.2026.10 fails its test suite on aarch64-darwin (6 VegaTest cases).
      # Use the cached build from the stable input until that is fixed upstream.
      plantuml = inputs.nixpkgs-nixos.legacyPackages.${prev.stdenv.hostPlatform.system}.plantuml;
    })
  ];
}
