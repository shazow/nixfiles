let hashedPassword = import ./.hashedPassword.nix; in  # Make with mkpasswd (see Makefile)

{ config, pkgs, lib, ... }:

{
  services.localtime.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.blacklistedKernelModules = [ "mei_me" ];
  boot.extraModprobeConfig = ''
     options cfg80211 ieee80211_regdom=US
     options snd_hda_intel power_save=1 power_save_controller=Y
  '';
  #hardware.enableAllFirmware = true;  # This pulls in everything, including Mac hardware etc.
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl intel-media-driver ];

  # Bluetooth
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.powertop.enable = true; # Run powertop --auto-tune on start

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
    gnupg

    # Other
    android-udev-rules
    alsa-firmware

    # Wireless
    bluez
    iw # wireless tooling
    crda # wireless regulatory agent
    wireless-regdb
  ];

  services.udev = {
    # FIXME: Monitor with `udevadm monitor --property`
    # FIXME: Need ENV{XAUTHORITY}="/home/shazow/.Xauthority"?
    # TODO: Add bluetooth remove lock event? ACTION=="remove", SUBSYSTEM=="bluetooth", ATTRS{address}=="00:00:00:00:00:00", ENV{DISPLAY}=":0", RUN+="su shazow -c screenlock"
    #   Could also use rssi or lq to check signal strength. Maybe we want to launch a signal strength poller on add that dies when the device disappears, and changes the lock settings?
    #extraRules = ''
    #  ACTION=="change", SUBSYSTEM=="drm", HOTPLUG=="1", ENV{DISPLAY}=":0", RUN+="xrandr --auto"
    #'';
  };

  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "2001:4860:4860::8844" "100.100.100.100" ];
  #networking.networkmanager.appendNameservers = [ "1.1.1.1" "8.8.8.8" "2001:4860:4860::8844" ];
  networking.hostName = "shazowic-corvus";
  networking.search = [ "shazow.gmail.com.beta.tailscale.net" ];
  networking.resolvconf.dnsExtensionMechanism = false; # Remove edns0 option in resolv.conf: Breaks some public WiFi but it is required for DNSSEC.
  networking.networkmanager.wifi.backend = "iwd"; # "wpa_supplicant" is default
  networking.networkmanager.wifi.macAddress = "permanent";  # One of "preserve", "random", "stable", "permanent", "00:11:22:33:44:55"
  networking.networkmanager.wifi.powersave = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Started on-demand by docker.socket
  };

  users.users.shazow = {
    isNormalUser = true;
    home = "/home/shazow";
    description = "shazow";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev" "adbusers" "docker"];
    uid = 1000;
    hashedPassword = hashedPassword;
  };

  users.users.andrey = {
    isNormalUser = true;
    home = "/home/andrey";
    description = "andrey";
    uid = 1100;
    hashedPassword = hashedPassword;
  };

  # Agent daemon required for pinentry
  programs.gnupg.agent.enable = true;

  # Android dev
  programs.adb.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03";
}
