{ inputs, pkgs, lib, hostname, userConfig, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote

    ../../modules/nixos/sway.nix
  ];

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

  environment.systemPackages = with pkgs; [ 
    vim git wget curl htop 
    pkgs.sbctl 
    file          # identify file types
    dmidecode     # firmware and DMI tables; needs sudo
    pciutils      # provides lspci
    lshw          # hardware listing; run with sudo for full detail
    usbutils      # provides lsusb
  ];

  services.power-profiles-daemon.enable = false;   # already false; stated so it stays that way
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";           # with amd-pstate-epp, the EPP does the work
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;
      RUNTIME_PM_ON_BAT = "auto";
      USB_AUTOSUSPEND = 1;
      WIFI_PWR_ON_BAT = "off";                            # rtw88 Wi-Fi power saving can cause dropouts
    };
  };

  services.openssh.enable = true;   # remove if you do not want inbound SSH
  services.fwupd.enable = true;

  # Set once to the release you install; do not bump it on upgrades.
  system.stateVersion = "26.05";
}
