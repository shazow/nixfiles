# Full disk encryption using a btrfs filesystem with encrypted /boot and a
# separate swap device.
#
# TODO:
# - Investigate what `nixos-generate-config --root /mnt` provides and how to
# integrate with the disk.nix config.
# 
# References:
# - https://gist.github.com/ladinu/bfebdd90a5afd45dec811296016b2a3f
# - Single password unlock: https://github.com/NixOS/nixpkgs/issues/24386
# - Password reuse: https://github.com/NixOS/nixpkgs/pull/29441
# - FDE example: https://github.com/Chiiruno/configuration/blob/master/etc/nixos/boot.nix
#
let disk = import ../disk.nix;
in
{
  boot.loader.systemd-boot.enable = true;

  # EFI
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Grub
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev"; # Use EFI as the bootloader
    efiSupport = true;
    enableCryptodisk = true;
    extraInitrd = disk.extraInitrd; # Replaced by boot.initrd.secrets? https://github.com/NixOS/nixpkgs/issues/41608
    # efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
  };

  # Once boot.initrd.secrets is a thing again... (See above)
  #boot.initrd.secrets = {
  #  "${disk.keyFile}" = disk.keyFile;
  #};

  # Resume
  boot.resumeDevice = "/dev/mapper/cryptswap";

  # LUKS
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.initrd.luks.devices =
  let
    keyFile = disk.keyFile;
  in
  {
    cryptroot = { device = disk.cryptroot; allowDiscards = true; keyFile = keyFile; };
    cryptswap = { device = disk.cryptswap; allowDiscards = true; keyFile = keyFile; };
  };

  # Filesystems
  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "nodiratime" "compress=lzo" "autodefrag" "commit=100" "subvol=@rootnix" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "compress=lzo" "autodefrag" "subvol=@home" ];
  };

  fileSystems."/boot/efi" = {
    label = "uefi";
    device = disk.efi;
    fsType = "vfat";
    options = [ "discard" ];
  };

  swapDevices = [
    { device = "/dev/mapper/cryptswap"; }
  ];
}
