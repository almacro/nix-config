# Everything: core + all optional groups. This is the "fat" aggregate imported
# by full hosts (the Macs, blackfish). Leaner hosts import core directly and
# pull only the groups they need — e.g. home/almacro/nixvm imports core only,
# and a future nixvm-fat could import core + a chosen subset of groups.
{ nhModules, ... }:
{
  imports = [
    "${nhModules}/core"
    "${nhModules}/groups/lisp-jvm.nix"
    "${nhModules}/groups/web.nix"
    "${nhModules}/groups/python.nix"
    "${nhModules}/groups/rust.nix"
    "${nhModules}/groups/systems.nix"
    "${nhModules}/groups/docs.nix"
    "${nhModules}/groups/cloud.nix"
    "${nhModules}/groups/data.nix"
  ];
}
