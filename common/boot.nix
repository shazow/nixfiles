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
{
  disk ? import ../disk.nix,
  ...
}:
let
  btrfsOptions = [
    "defaults"
    "noatime"
    "compress=lzo"
    "noautodefrag" # FIXME: Switch back to "autodefrag" once 5.16.5+ is out: https://www.reddit.com/r/selfhosted/comments/sgy96t/psa_linux_516_has_major_regression_in_btrfs/
  ];
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
    options = btrfsOptions ++ [ "nodiratime" "commit=100" "subvol=@rootnix" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = btrfsOptions ++ [ "subvol=@home" ];
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
