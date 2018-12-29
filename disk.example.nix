# cp disk.example.nix disk.nix
{
  extraInitrd = ./initrd.keys.gz;
  keyFile = "cryptroot.key";
  efi = /dev/nvme0n1p1;
  cryptswap = /dev/nvme0n1p2;
  cryptroot = /dev/nvme0n1p3;
}
