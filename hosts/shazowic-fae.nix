{
  inputs,
  pkgs,
  initialHashedPassword,
  disk,
  ...
}:
{
  system = "x86_64-linux";

  modules = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  home = [
    ./home/portable.nix
  ];

  imports = [
    ./hardware/framework-13-amd.nix
    (import ./common/boot.nix {
      inherit disk;
    })
    ./common/desktop-i3.nix
    ./common/crypto.nix
    ./common/guest.nix
  ];

  # Palm rejection during typing for x11
  services.xserver.libinput.touchpad.disableWhileTyping = true;

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
}
