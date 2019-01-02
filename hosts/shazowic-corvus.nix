let hashedPassword = import ./.hashedPassword.nix; in  # Make with mkpasswd (see Makefile)

{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.blacklistedKernelModules = [ "mei_me" ];
  hardware.enableAllFirmware = true;

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [
    ./common/hardware-thinkpad-x1c.nix
    ./common/boot.nix
    ./common/desktop.nix
  ];

  environment.systemPackages = with pkgs; [
    # System
    acpi
    binutils-unwrapped
    fd
    fwupd
    htop
    lm_sensors
    p7zip
    pciutils
    powertop
    psmisc
    ripgrep
    sysstat
    tree
    unzip

    # Desktop
    alsaTools
    blueman
    networkmanagerapplet
    clipnotify
    dunst
    feh
    i3lock
    i3status-rust
    libnotify
    maim
    pavucontrol
    pcmanfm
    rofi
    xss-lock
    xsel

    # Apps
    alacritty
    cargo
    discord
    gnupg
    go
    google-chrome-beta
    python3
    signal-desktop
    vlc

    # Fonts
    dejavu_fonts
    font-awesome-ttf
  ];
  services.clipmenu.enable = true;
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

  boot.loader.grub.extraEntries = import ./archboot.nix;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
