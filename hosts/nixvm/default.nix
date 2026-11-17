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
    # TODO: set real auth BEFORE exposing the VM. Prefer an SSH key:
    #   openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... you@host" ];
    # or a hashed password (`mkpasswd -m sha-512`): hashedPassword = "...";
    initialPassword = "changeme";
  };
  security.sudo.wheelNeedsPassword = true;

  # zsh must be enabled system-wide to be a valid login shell (home-manager
  # common configures the interactive bits).
  programs.zsh.enable = true;

  # --- Remote access ------------------------------------------------------
  services.openssh = {
    enable = true;
    # Tighten to key-only once authorizedKeys are set above.
    settings.PasswordAuthentication = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Set to the NixOS release you install from; do NOT change casually after
  # install (it governs stateful-data compatibility).
  system.stateVersion = "25.05";
}
