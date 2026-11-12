{ pkgs, lib, hostname, userConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader: systemd-boot on the unencrypted ESP
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;     # keeps the ESP from filling with old generations
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;          # "blackfish"
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.${userConfig.name} = {
    isNormalUser = true;
    description = userConfig.fullName;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [ vim git wget curl htop ];

  services.openssh.enable = true;   # remove if you do not want inbound SSH

  # Set once to the release you install; do not bump it on upgrades.
  system.stateVersion = "26.05";
}
