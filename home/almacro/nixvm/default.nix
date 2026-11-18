{ nhModules, ... }:
{
  imports = [
    "${nhModules}/common"
  ];

  # VM-specific home packages / config go here. The shared `common` module
  # already brings the cross-platform toolchain (its darwin-only bits are
  # guarded by isDarwin, so they no-op on this Linux guest).
}
