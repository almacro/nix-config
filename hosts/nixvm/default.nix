{
  lib,
  pkgs,
  userConfig,
  hostname,
  ...
}:
{
  imports = [
    # Generated inside the VM at install time (see hardware-configuration.nix).
    ./hardware-configuration.nix
  ];

  # --- Boot ---------------------------------------------------------------
  # vfkit boots an EFI disk; systemd-boot on the ESP is the simplest setup.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Apple Virtualization / vfkit exposes a virtio console as hvc0.
  boot.kernelParams = [ "console=hvc0" ];

  # --- Networking ---------------------------------------------------------
  # vfkit provides NAT networking (via gvproxy); DHCP inside the guest.
  networking.hostName = hostname;
  networking.useDHCP = lib.mkDefault true;

  # --- Nix ----------------------------------------------------------------
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # --- Users --------------------------------------------------------------
  users.users.${userConfig.name} = {
    isNormalUser = true;
    description = userConfig.fullName;
    extraGroups = [ "wheel" ]; # sudo
    shell = pkgs.zsh;
    # Key-only login; no password is set on this account at all. Add/replace
    # keys here as needed (public keys are safe to commit).
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMssjPRMXKE0lVMdOu2XUK9iQqqgONnl0QSI6lkGka2r alm4x1mu5@gmail.com"
    ];
  };
  # The user has no password, so sudo must NOT prompt for one — otherwise wheel
  # members could never escalate. Acceptable for this throwaway VM.
  security.sudo.wheelNeedsPassword = false;

  # zsh must be enabled system-wide to be a valid login shell (home-manager
  # common configures the interactive bits).
  programs.zsh.enable = true;

  # --- Remote access ------------------------------------------------------
  services.openssh = {
    enable = true;
    # Key-only: never accept passwords over SSH (the account has none anyway).
    settings.PasswordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Set to the NixOS release you install from; do NOT change casually after
  # install (it governs stateful-data compatibility).
  system.stateVersion = "25.05";
}
