let hashedPassword = import ./.hashedPassword.nix; in  # Make with mkpasswd (see Makefile)

{ config, pkgs, lib, ... }:

{
  services.localtime.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_5_0; # 5.1 is buggy?
  #boot.kernelPackages = pkgs.linuxPackages_latest;
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
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl intel-media-driver ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    ./hardware/thinkpad-x1c.nix
    ./common/boot.nix
    ./common/desktop-i3.nix
  ];

  networking.firewall.allowedTCPPorts = [
    8010  # VLC Chromecast
  ];

  environment.systemPackages = with pkgs; [
    home-manager

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
    gnupg
    google-chrome-beta

    # Other
    alsa-firmware
  ];

  services.udev = {
    extraRules = ''
      ACTION=="change", SUBSYSTEM=="drm", HOTPLUG=="1", RUN+="xrandr --auto"
    '';
  };

  #services.dnsmasq.enable = true;
  #services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.networkmanager.appendNameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
  networking.hostName = "shazowic-corvus";
  networking.networkmanager.wifi.macAddress = "preserve";  # Or "random", "stable", "permanent", "00:11:22:33:44:55"

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
