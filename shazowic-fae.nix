{
  pkgs, lib,
  initialHashedPassword,
  disk,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # $ nixos-generate-config --show-hardware-config
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    (import ./common/boot.nix {
      inherit disk;
    })
    ./common/desktop-i3.nix
    ./common/crypto.nix
    ./common/guest.nix
  ];

  # Hardware specific
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.extraPackages = [
    pkgs.rocmPackages.clr.icd
    # Encoding/decoding acceleration
    pkgs.libvdpau-va-gl pkgs.vaapiVdpau
  ];
  hardware.opengl.extraPackages32 = [ ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.fwupd.enable = true;
  services.blueman.enable = true;
  services.fprintd.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

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

  networking.hostName = "shazowic-fae";
  networking.search = [ "shazow.gmail.com.beta.tailscale.net" ];
  #networking.resolvconf.dnsExtensionMechanism = false; # Remove edns0 option in resolv.conf: Breaks some public WiFi but it is required for DNSSEC.
  networking.networkmanager.wifi.backend = "iwd"; # "wpa_supplicant" is default
  networking.networkmanager.wifi.macAddress = "stable"; # One of "preserve", "random", "stable", "permanent", "00:11:22:33:44:55"
  networking.networkmanager.wifi.powersave = true;

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
    initialHashedPassword = initialHashedPassword;
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
