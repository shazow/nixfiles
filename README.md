# nixfiles

Some of my .nix files

## Installing

### Disk Setup

Rough sketch of the expected disk layout with full-disk encryption.

**NOTE**: If trying in a VM, make sure to use a SCSI virtual disk (instead of HDA) and UEFI enabled.

```bash
# Setup partition layout
# Swap should be >RAM size if you're going to use hibernate
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB  # boot
parted /dev/sda -- set 1 boot on
parted /dev/sda -- mkpart primary 512MiB -1GiB  # root
parted /dev/sda -- mkpart primary linux-swap -1GiB 100%  # swap

# Encrypt the partitions
# Swap partition is also encrypted, so our hibernate state is encrypted.
# We use luks1 (instead of luks2) because grub2 only supports luks1 for now.
# Follow: https://github.com/NixOS/nixpkgs/issues/65375 for LUKS2 on Grub
# To convert, see: https://cryptsetup-team.pages.debian.net/cryptsetup/encrypted-boot.html
cryptsetup luksFormat --type luks1 /dev/sda2  # Enter password
cryptsetup luksFormat --type luks1 /dev/sda3  # Enter the same password

# Generate root private key file
# Can skip this if we don't want key-unlock support. Can be handy for things like USB-unlock.
if [[ ! -f cryptroot.key ]]; then
  dd if=/dev/urandom of=cryptroot.key bs=1 count=4096
  chmod 0400 cryptroot.key
  cryptsetup luksAddKey /dev/sda2 cryptroot.key
  cryptsetup luksAddKey /dev/sda3 cryptroot.key
fi

# Open the encrypted partitions
cryptsetup open /dev/sda2 cryptroot
cryptsetup open /dev/sda3 cryptswap

# Format the underlying partitions
mkfs.fat -F 32 -n EFI /dev/sda1  # Unencrypted EFI partition
mkswap /dev/mapper/cryptswap
mkfs.btrfs /dev/mapper/cryptroot
mount -o defaults,noatime,compress=lzo,autodefrag /dev/mapper/cryptroot /mnt

# Create volumes on the btrfs root
btrfs subvolume create /mnt/@rootnix
btrfs subvolume create /mnt/@boot
btrfs subvolume create /mnt/@home

# Remount with new volumes
umount /mnt
mount -o compress=lzo,subvol=@rootnix /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot /mnt/home
mount -o compress=lzo,subvol=@boot /dev/mapper/cryptroot /mnt/boot
mount -o compress=lzo,subvol=@home /dev/mapper/cryptroot /mnt/home
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
```

Resume an existing disk setup:

```bash
cryptsetup open /dev/sda2 cryptroot  # Enter password
cryptsetup open /dev/sda3 cryptswap  # Enter password

mount -o compress=lzo,subvol=@rootnix /dev/mapper/cryptroot /mnt
mount -o compress=lzo,subvol=@boot /dev/mapper/cryptroot /mnt/boot
mount -o compress=lzo,subvol=@home /dev/mapper/cryptroot /mnt/home
mount /dev/sda1 /mnt/boot/efi
```

### NixOS Setup from another distro

If you're installing from inside another distro, you can use these instructions: https://nixos.org/nixos/manual/index.html#sec-installing-from-other-distro

In Arch, using the aur/nix package [does not work](https://github.com/shazow/nixfiles/issues/3).

If we need to add hardware-specific configuration imports, we'll need [nixos-hardware (setup instructions)](https://github.com/NixOS/nixos-hardware#setup). The nix environment activator only includes the nixpkgs channel in the NIX_PATH by default, so we'll need to add that too.

```bash
# Activate the nix environment
. $HOME/.nix-profile/etc/profile.d/nix.sh

# Add the nixos-hardware channel
nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
nix-channel --update nixos-hardware

# Add the new channel to our NIX_PATH
export NIX_PATH=${NIX_PATH}:${NIX_PATH//nixpkgs/nixos-hardware}
```

Some other notes for installing from another distro (doesn't apply for a normal install):
- `${disk.efi}` should be mounted to `/mnt/boot/efi` (or whatever the root prefix is).
- `${disk.extraInitrd}` should be an absolute path under the root prefix (otherwise when we install outside the root prefix, it messes up the path).

After that, off we go:

```bash
sudo groupadd -g 30000 nixbld
sudo useradd -u 30000 -g nixbld -G nixbld nixbld
sudo PATH="$PATH" NIX_PATH="$NIX_PATH" `which nixos-install` --root /mnt
```


### NixOS Setup from scratch (in a VM)

```bash
curl -Ls "https://github.com/shazow/nixfiles/archive/master.zip" -o nixfiles.zip
unzip nixfiles.zip

mkdir /mnt/etc
mv nixfiles-master /mnt/etc/nixos

cd /mnt/etc/nixos
echo \"$(mkpasswd -m sha-512)\" > .hashedPassword.nix
chmod 400 .hashedPassword.nix

# TODO: Make initrd.keys.gz (see Makefile)

cat > disk.nix << EOF
{
  extraInitrd = ./initrd.keys.gz;
  keyFile = "cryptroot.key";
  cryptroot = "/dev/sda2";
  cryptswap = "/dev/sda3";
  efi = "/dev/sda1";
}
EOF

cp hosts/example.nix configuration.nix
echo "Edit configuration.nix ... Some of the paths are wrong here, need to fix."

nixos-install --root /mnt
```


## References

Big thanks to my friend group of NixOS pioneers who paved through the unknowns, and answered many questions along the way.

- [@arilotter](https://github.com/arilotter) and https://github.com/arilotter/dotfiles
- [@attente](https://github.com/attente) and https://github.com/attente/dotfiles
- Bonus shoutout to [@jpf](https://github.com/jpf) for checking out NixOS long before it was cool

### Full Disk Encryption (FDE)

- https://nixos.wiki/wiki/Full_Disk_Encryption
- https://gist.github.com/ladinu/bfebdd90a5afd45dec811296016b2a3f
- https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134
