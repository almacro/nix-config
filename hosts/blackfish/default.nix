{ pkgs, lib, hostname, userConfig, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix inputs.lanzaboote.nixosModules.lanzaboote ];

  # Bootloader: systemd-boot on the unencrypted ESP
  boot.loader.systemd-boot = {
    enable = lib.mkForce false;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # tell the initrd to use the TPM
  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 10;     # keeps the ESP from filling with old generations
  };
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

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

  environment.systemPackages = with pkgs; [ vim git wget curl htop pkgs.sbctl ];

  services.openssh.enable = true;   # remove if you do not want inbound SSH

  # Set once to the release you install; do not bump it on upgrades.
  system.stateVersion = "26.05";
}
