# PLACEHOLDER hardware configuration.
#
# Replace this file with the one generated INSIDE the vfkit VM after the first
# NixOS install:  `nixos-generate-config` writes /etc/nixos/hardware-configuration.nix
# — copy that here. The values below are typical for a vfkit guest (virtio-blk
# disk => /dev/vda, ESP + ext4 root by label) and exist only so the flake
# evaluates before the VM is installed.
{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix") # virtio drivers (vfkit is virtio-based)
  ];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
