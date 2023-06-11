let
  # Make with mkpasswd (see Makefile)
  hashedPassword = import ./.hashedPassword.nix;
in

{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.blacklistedKernelModules = [
    "mei_me"
    "snd_hda_intel" # No motherboard audio, this device uses a USB DAC instead
  ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2 swap_opt_cmd=1
  '';
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl vaapiVdpau ];


  # Bluetooth
  #services.blueman.enable = true;
  #hardware.bluetooth.enable = true;
  #hardware.bluetooth.powerOnBoot = false;

  nix.settings.max-jobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    <nixos-hardware/common/cpu/amd>
    ./common/boot.nix
    ./common/desktop-i3.nix
  ];

  # Hardware specific
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.steam-hardware.enable = true; # VR
  hardware.nvidia.modesetting.enable = true; # Nvidia, needed for vaapi? https://github.com/NixOS/nixpkgs/issues/169245
  hardware.i2c.enable = true; # For controlling displays with ddcutil
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.dpi = 163; # 3840x2160 over 27"
  services.fwupd.enable = true;
  networking.interfaces.enp0s31f6 = {
    useDHCP = true;
    wakeOnLan.enable = true;
  };
  #networking.interfaces.wlp0s20f0u12.useDHCP = true;

  networking.firewall.allowedTCPPorts = [
    8010 # VLC Chromecast
  ];

  services.openssh = {
    enable = true;
    startWhenNeeded = true; # Don't start until socket request comes in to systemd
    settings = {
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    home-manager

    # Desktop
    alsa-tools
    arandr
    colord
    dunst
    feh
    libnotify
    maim
    openvpn
    pavucontrol

    # Apps
    gnupg

    # Other
    android-udev-rules
    alsa-firmware

    # Wireless
    iw # wireless tooling
    crda # wireless regulatory agent
    wireless-regdb
  ];

  networking.hostName = "shazowic-beast";
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.wifi.macAddress = "permanent"; # One of "preserve", "random", "stable", "permanent", "00:11:22:33:44:55"

  services.udev.extraRules = ''
    # KeepKey HID Firmware/Bootloader
    SUBSYSTEM=="usb", ATTR{idVendor}=="2b24", ATTR{idProduct}=="0001", MODE="0666", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl", SYMLINK+="keepkey%n"
    KERNEL=="hidraw*", ATTRS{idVendor}=="2b24", ATTRS{idProduct}=="0001",  MODE="0666", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"

    # KeepKey WebUSB Firmware/Bootloader
    SUBSYSTEM=="usb", ATTR{idVendor}=="2b24", ATTR{idProduct}=="0002", MODE="0666", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl", SYMLINK+="keepkey%n"
    KERNEL=="hidraw*", ATTRS{idVendor}=="2b24", ATTRS{idProduct}=="0002",  MODE="0666", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Add Ledger hardware wallet support. Requires plugdev group to exist.
  hardware.ledger.enable = true;
  users.groups.plugdev = { };

  services.syncthing = {
    enable = true;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Started on-demand by docker.socket
  };

  users.users.shazow = {
    isNormalUser = true;
    home = "/home/shazow";
    description = "shazow";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev" "dialout" "adbusers" "docker" "i2c" ];
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
  system.stateVersion = "23.05";
}
