{ config, lib, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.blacklistedKernelModules = [ "mei_me" ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    ./common/boot.nix
    ./common/desktop.nix
    <nixos-hardware/lenovo/thinkpad/x1/6th-gen/QHD>
  ];

  networking.hostName = "shazowic-corvus";

  users.users.shazow = {
    isNormalUser = true;
    home = "/home/shazow";
    description = "shazow";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev"];
    uid = 1000;
    hashedPassword = let hashedPassword = import ./.hashedPassword.nix; in hashedPassword; # Make with mkpasswd
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
