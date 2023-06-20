# Default disk values, can be overridden when passed into common/boot.nix
{
  efi = "/dev/nvme0n1p1";
  cryptswap = "/dev/nvme0n1p2";
  cryptroot = "/dev/nvme0n1p3";
}
