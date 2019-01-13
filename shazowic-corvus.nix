let hashedPassword = import ./.hashedPassword.nix; in  # Make with mkpasswd (see Makefile)

{ config, pkgs, lib, ... }:

{
  time.timeZone = "America/Toronto";

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.blacklistedKernelModules = [ "mei_me" ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    ./common/hardware-thinkpad-x1c.nix
    ./common/boot.nix
    ./common/desktop-i3.nix
  ];

  environment.systemPackages = with pkgs; [
    # Desktop
    alsaTools
    arandr
    blueman
    dunst
    feh
    libnotify
    maim
    openvpn
    pavucontrol
    xclip
    xdotool
    xsel

    # Apps
    alacritty
    discord
    gnupg
    google-chrome-beta
    signal-desktop
    vlc

    # Build
    cargo
    python3
    gcc
    go
    nodejs-10_x
  ];
  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

  networking.hostName = "shazowic-corvus";

  users.users.shazow = {
    isNormalUser = true;
    home = "/home/shazow";
    description = "shazow";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev"];
    uid = 1000;
    hashedPassword = hashedPassword;
  };

  boot.loader.grub.extraEntries = import ./.extraboot.nix;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
