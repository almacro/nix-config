{ pkgs, ... }:
{
  home.packages = with pkgs; [
    postgresql # psql client
    protobuf
  ];
}
