# This gets replaced on the fly by nixos-anywhere with --generate-hardware-config
# but this stub should work too.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
