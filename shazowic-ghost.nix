{ config, lib,
  initialHashedPassword,
  ...
}:
{
  boot.blacklistedKernelModules = [ "mei_me" ];
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod" ];
  nix.maxJobs = lib.mkDefault 2;
  virtualisation.virtualbox.guest.enable = true;

  imports = [
    ./common/boot.nix
    ./common/server.nix
  ];
  networking.hostName = "shazowic-ghost";

  users.extraUsers.shazow = {
    isNormalUser = true;
    home = "/home/shazow";
    description = "shazow";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager"];
    uid = 1000;
    initialHashedPassword = initialHashedPassword;
  };

  system.stateVersion = "23.05";
}
