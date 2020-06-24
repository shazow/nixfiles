# cp disk.example.nix disk.nix
{
  efi = "/dev/nvme0n1p1";
  cryptswap = "/dev/nvme0n1p2";
  cryptroot = "/dev/nvme0n1p3";
}
