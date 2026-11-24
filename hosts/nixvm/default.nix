{
  lib,
  pkgs,
  options,
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
  # Bound ESP usage; 5 generations is ample rollback for a throwaway VM (a full
  # ESP is already loud — the bootloader step fails during nixos-rebuild). Use
  # `df -h /boot` as the manual check.
  boot.loader.systemd-boot.configurationLimit = 5;
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
  # Advertise/resolve <hostname>.local over mDNS so the Mac can reach the VM
  # by name (nixvm.local) without it, that name won't resolve.
  services.avahi = lib.mkMerge [
    { enable = true; nssmdns4 = true; }
    (if options.services.avahi ? settings then {
      # nixpkgs 26.11 and later
      settings.publish = {
        disable-publishing = false;
        publish-addresses = true;       # publish A/AAAA for <hostname>.local
      };
    } else {
      # nixpkgs 26.05 (stable): remove this branch once nixpkgs-nixos moves to 26.11
      publish = { enable = true; addresses = true; };
    })
  ];

  # --- Nix ----------------------------------------------------------------
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # --- Slim profile (keep the throwaway VM small) -------------------------
  # mkDefault throughout so a future fat profile can override with plain
  # values (no mkForce needed).
  zramSwap.enable = lib.mkDefault true; # compressed RAM swap vs a disk device
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = lib.mkDefault true;
  documentation.enable = lib.mkDefault false; # drop man/info/nixos docs

  # --- Users --------------------------------------------------------------
  users.users.${userConfig.name} = {
    isNormalUser = true;
    description = userConfig.fullName;
    extraGroups = [ "wheel" ]; # sudo
    shell = pkgs.zsh;
    # SSH login is key-only. Public keys are safe to commit; the comment uses
    # the GitHub noreply address (no personal email exposed). Verified against
    # the private key ~/.ssh/id_ed25519_almacro.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMssjPRMXKE0lVMdOu2XUK9iQqqgONnl0QSI6lkGka2r 27452+almacro@users.noreply.github.com"
    ];
    # Console-login fallback for recovery if key/SSH access breaks. The hash
    # lives ON THE VM, never in this repo. Create it after install:
    #   sudo mkdir -p /etc/secrets
    #   nix-shell -p mkpasswd --run 'mkpasswd -m sha-512' \
    #     | sudo tee /etc/secrets/almacro.hash
    #   sudo chmod 600 /etc/secrets/almacro.hash
    # If the file is absent, NixOS warns during activation and the account has
    # no console password (key-only) — confirm this in your first switch output.
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
    # Key-only. Disable BOTH password and keyboard-interactive: once a console
    # hashedPasswordFile exists, keyboard-interactive would otherwise let SSH
    # accept that password through PAM despite PasswordAuthentication = false.
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # The NixOS release you install from (26.05 ISO). Do NOT change after the
  # first install — it governs stateful-data compatibility.
  system.stateVersion = "26.05";
}
