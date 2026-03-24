{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
  [ (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
}
