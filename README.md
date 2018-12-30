# nixfiles

Some of my .nix files

## Installing

### Disk Setup

Rough sketch of the expected disk layout with full-disk encryption.

**NOTE**: If trying in a VM, make sure to use a SCSI virtual disk (instead of HDA) and UEFI enabled.

```console
# Setup partition layout
# Swap should be >RAM size if you're going to use hibernate
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB  # boot
parted /dev/sda -- set 1 boot on
parted /dev/sda -- mkpart primary 512MiB -1GiB  # root
parted /dev/sda -- mkpart primary linux-swap -1GiB 100%  # swap

# Generate root private key file
if [[ ! -f cryptroot.key ]]; then
  dd if=/dev/urandom of=cryptroot.key bs=1 count=4096
  chmod 0400 cryptroot.key
fi

# Encrypt the partitions
# Swap partition is also encrypted, so our hibernate state is encrypted.
cryptsetup luksFormat /dev/sda2  # Enter password
cryptsetup luksFormat /dev/sda3  # Enter the same password
cryptsetup luksAddKey /dev/sda2 cryptroot.key
cryptsetup luksAddKey /dev/sda3 cryptroot.key

# Open the encrypted partitions
cryptsetup open -d cryptroot.key /dev/sda2 cryptroot
cryptsetup open -d cryptroot.key /dev/sda3 cryptswap

# Format the underlying partitions
mkfs.fat -F 32 -n efi /dev/sda1
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

```console
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

To add hardware-specific configuration imports (like these nixfiles use), we'll need [nixos-hardware (setup instructions)](https://github.com/NixOS/nixos-hardware#setup).

The nix environment activator only includes the nixpkgs channel in the NIX_PATH by default, so we'll need to add that too:

```console
export NIXPATH=${NIXPATH}:${NIX_PATH//nixpkgs/nixos-hardware}
```

After that, off we go:

```console
sudo PATH="$PATH" NIX_PATH="$NIX_PATH" `which nixos-install` --root /mnt
```


### NixOS Setup from scratch (in a VM)

```console
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
