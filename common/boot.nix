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
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
    editor = false; # Disable bypassing init
  };

  boot.loader.grub.enable = false; # Use systemd-boot instead

  # EFI
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Resume
  boot.resumeDevice = "/dev/mapper/cryptswap";

  # LUKS
  boot.initrd.supportedFilesystems = [ "btrfs" "ntfs" ];
  boot.initrd.luks.devices = {
    cryptroot = { device = disk.cryptroot; };
    cryptswap = { device = disk.cryptswap; };
  };

  # Filesystems
  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "noatime" "nodiratime" "compress=lzo" "autodefrag" "commit=100" "subvol=@rootnix" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "noatime" "compress=lzo" "autodefrag" "subvol=@home" ];
  };

  fileSystems."/boot/efi" = {
    label = "uefi";
    device = disk.efi;
    fsType = "vfat";
    options = [ ];
  };

  swapDevices = [
    { device = "/dev/mapper/cryptswap"; }
  ];
}
