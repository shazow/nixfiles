let hashedPassword = import ./.hashedPassword.nix; in  # Make with mkpasswd (see Makefile)

{ config, pkgs, lib, ... }:

{
  time.timeZone = "America/Toronto";
  services.localtime.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.blacklistedKernelModules = [ "mei_me" ];
  boot.extraModprobeConfig = ''
     options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
     options iwldvm force_cam=0
     options cfg80211 ieee80211_regdom=US
     options snd_hda_intel power_save=1 power_save_controller=Y
  '';
  hardware.enableAllFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    ./hardware/thinkpad-x1c.nix
    ./common/boot.nix
    ./common/desktop-i3.nix
  ];

  environment.systemPackages = with pkgs; [
    # Desktop
    alsaTools
    arandr
    blueman
    colord
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

    # Other
    alsa-firmware
  ];
  #services.dnsmasq.enable = true;
  #services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.networkmanager.appendNameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.hostName = "shazowic-corvus";

  #services.avahi.enable = true;
  #services.avahi.nssmdns = true;
  services.fwupd.enable = true;

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