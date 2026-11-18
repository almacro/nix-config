# Disk layout for the vfkit guest. Kept PERMANENTLY and by-label on purpose:
# do NOT replace it with `nixos-generate-config` output, which pins UUIDs that
# change whenever the disk image is recreated. Label-based mounts let the same
# config boot a freshly recreated image — format the disk to match:
#   ESP:  mkfs.fat -F32 -n ESP   /dev/vda1
#   root: mkfs.ext4      -L nixos /dev/vda2
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
    # The ESP holds boot files; keep it non-world-readable.
    options = [ "umask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
