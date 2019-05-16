{ config, lib, ... }:
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
    hashedPassword = let hashedPassword = import ./.hashedPassword.nix; in hashedPassword; # Make with mkpasswd
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
