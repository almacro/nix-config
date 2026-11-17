{
  lib,
  pkgs,
  userConfig,
  hostname,
  ...
}:
{
  imports = [
    # Permanent, label-based disk layout — kept on purpose (see the file).
    ./hardware-configuration.nix
  ];

  # --- Boot ---------------------------------------------------------------
  # vfkit boots an EFI disk; systemd-boot on the ESP is the simplest setup.
  boot.loader.systemd-boot.enable = true;
  # false is more robust on ARM UEFI: the firmware's EFI variable store isn't
  # always persistent, and systemd-boot still boots via the fallback path if
  # the variables are lost/recreated.
  boot.loader.efi.canTouchEfiVariables = false;
  # Apple Virtualization / vfkit exposes a virtio console as hvc0.
  boot.kernelParams = [ "console=hvc0" ];
  # Ensure a login prompt on that virtio console (console=hvc0 alone does not
  # guarantee a getty is spawned on hvc0).
  systemd.services."serial-getty@hvc0" = {
    enable = true;
    wantedBy = [ "getty.target" ];
  };

  # --- Networking ---------------------------------------------------------
  # With vfkit's `--device virtio-net,nat` the guest gets NAT from Apple's
  # Virtualization framework directly (NOT gvproxy — gvproxy only applies with
  # the unixgram/socket network backend). DHCP inside the guest.
  networking.hostName = hostname;
  networking.useDHCP = lib.mkDefault true;

  # --- Nix ----------------------------------------------------------------
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # --- Slim profile (keep the throwaway VM small) -------------------------
  zramSwap.enable = true; # compressed RAM swap instead of a disk swap device
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;
  documentation.enable = false; # drop man/info/nixos docs from the closure

  # --- Users --------------------------------------------------------------
  users.users.${userConfig.name} = {
    isNormalUser = true;
    description = userConfig.fullName;
    extraGroups = [ "wheel" ]; # sudo
    shell = pkgs.zsh;
    # SSH login is key-only (public keys are safe to commit; this one is
    # verified against ~/.ssh/id_ed25519_almacro).
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMssjPRMXKE0lVMdOu2XUK9iQqqgONnl0QSI6lkGka2r alm4x1mu5@gmail.com"
    ];
    # Console-login fallback for recovery if key/SSH access breaks. The hash
    # lives ON THE VM, never in this repo. Create it after install, e.g.:
    #   mkpasswd -m sha-512 | sudo tee /etc/secrets/almacro.hash
    #   sudo chmod 600 /etc/secrets/almacro.hash
    # If the file is absent the account stays key-only (no console password).
    hashedPasswordFile = "/etc/secrets/almacro.hash";
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

  # The NixOS release you install from (26.05 ISO). Do NOT change after the
  # first install — it governs stateful-data compatibility.
  system.stateVersion = "26.05";
}
