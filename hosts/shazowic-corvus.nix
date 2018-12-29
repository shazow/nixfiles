{ config, lib, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.blacklistedKernelModules = [ "mei_me" ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    <nixos-hardware/lenovo/thinkpad/x1/6th-gen/QHD>
    ./common/boot.nix
    ./common/desktop.nix
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

  services.tlp.extraConfig = ''
    START_CHARGE_THRESH_BAT0=75
    STOP_CHARGE_THRESH_BAT0=90
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    ENERGY_PERF_POLICY_ON_BAT=powersave
  '';

  # TODO: Figure out how to disable these...
  # Disable the "throttling bug fix" -_- https://github.com/NixOS/nixos-hardware/blob/master/common/pc/laptop/cpu-throttling-bug.nix
  #systemd.timers.cpu-throttling.enable = false;
  #systemd.services.cpu-throttling.enable = false;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Toronto";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
