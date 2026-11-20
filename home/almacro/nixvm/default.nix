{ nhModules, ... }:
{
  imports = [
    # Core only — the lean daily toolchain. Optional groups
    # (modules/home-manager/groups/*) are intentionally NOT imported here;
    # a future nixvm-fat can pull in whichever it needs.
    "${nhModules}/core"
  ];

  # VM-specific home packages / config go here.
}
