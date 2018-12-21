# nixfiles

Some of my .nix files

**Status**: WIP. Trying to craft a combined config across many references, then going to try it on a VM, then going to try and migrate my own installs gracefully. Haven't run this yet so it probably doesn't work.

## Installing

```
curl -Ls "https://github.com/shazow/nixfiles/archive/master.zip" -o nixfiles.zip
unzip nixfiles.zip
cd nixfiles-master
```

### Disk Setup

Rough sketch of the expected disk layout with full-disk encryption:

```
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 boot on
parted /dev/sda -- mkpart primary 512MiB -1GiB
parted /dev/sda -- mkpart primary linux-swap -1GiB 100%

if [[ ! -f cryptroot.key ]]; then
  dd if=/dev/urandom of=cryptroot.key bs=1 count=4096
  chmod 0400 cryptroot.key
fi

cryptsetup luksFormat /dev/sda2  # Enter password
cryptsetup luksFormat /dev/sda3  # Enter the same password
cryptsetup luksAddKey /dev/sda2 cryptroot.key
cryptsetup luksAddKey /dev/sda3 cryptroot.key

cryptsetup open -d cryptroot.key /dev/sda2 cryptroot
cryptsetup open -d cryptroot.key /dev/sda3 cryptswap

mkfs.fat -F 32 -n efi /dev/sda1
mkswap /dev/mapper/cryptswap
mkfs.btrfs /dev/mapper/cryptroot
mount -o defaults,noatime,compress=lzo,autodefrag /dev/mapper/cryptroot /mnt

btrfs subvolume create /mnt/@rootnix
btrfs subvolume create /mnt/@boot
btrfs subvolume create /mnt/@home

umount /mnt

mount -o compress=lzo,subvol=@rootnix /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot /mnt/home
mount -o compress=lzo,subvol=@boot /dev/mapper/cryptroot /mnt/boot
mount -o compress=lzo,subvol=@home /dev/mapper/cryptroot /mnt/home
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
```



## References

Big thanks to my friend group of NixOS pioneers who paved through the unknowns, and answered many questions along the way.

- [@arilotter](https://github.com/arilotter) and https://github.com/arilotter/dotfiles (which heavily inspired my layout)
- [@attente](https://github.com/attente) and his yet-unpublished configs
- Bonus shoutout to [@jpf](https://github.com/jpf) for checking out NixOS long before it was cool

### Full Disk Encryption (FDE)

- https://nixos.wiki/wiki/Full_Disk_Encryption
- https://gist.github.com/ladinu/bfebdd90a5afd45dec811296016b2a3f
- https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134
