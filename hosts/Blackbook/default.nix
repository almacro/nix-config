{ darwinModules, ... }:
{
  imports = [
    "${darwinModules}/common"
  ];

  homebrew.casks = [
    "microsoft-remote-desktop"
  ];
}
