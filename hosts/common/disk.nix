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
#
let disk = import ../../disk.nix;
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
    device = disk.bootDevice;
    efiSupport = true;
    enableCryptodisk = true;
    extraInitrd = /boot/initrd.keys.gz;
  }

  # Resume
  boot.resumeDevice = "/dev/cryptswap";

  # LUKS
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.initrd.luks.devices =
  let
    keyFile = disk.keyFile;
  in
  [
    { name = "cryptroot"; device = "${disk.cryptroot}"; allowDiscards = true; keyFile = keyFile; }
    { name = "cryptswap"; device = "${disk.cryptswap}"; allowDiscards = true; keyFile = keyFile; }
  ];

  # Filesystems
  filesystems."/" = {
    device = "/dev/mapper/cryptroot";
    fstype = "btrfs";
    options = [ "defaults","noatime","nodiratime","compress=lzo","autodefrag","commit=100","subvol=@rootnix" ];
  };

  filesystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fstype = "btrfs";
    options = [ "defaults","noatime","compress=lzo","autodefrag","subvol=@home" ];
  };

  filesystems."/boot" = {
    device = "/dev/mapper/cryptroot";
    fstype = "btrfs";
    options = [ "defaults","noatime","compress=lzo","autodefrag","subvol=@home" ];
  };

  swapDevices = [
    { device = "/dev/mapper/cryptswap"; }
  ];
}
