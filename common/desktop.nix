{ pkgs, lib, hostname, primaryUsername, initialHashedPassword, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Turn off screen after 60s in console
  boot.kernelParams = [ "consoleblank=60" ];

  # Desktop environment agnostic packages.
  environment.systemPackages = with pkgs; [
    home-manager

    acpi
    bind # nslookup etc
    binutils-unwrapped
    dmidecode
    fd
    git
    gnumake
    htop
    inetutils
    lm_sensors
    mkpasswd
    (neovim.override {
      vimAlias = true;
    })
    nfs-utils
    pamixer # pulseaudio mixer cli, usable with pipewire
    patchelf
    pciutils # lspci
    powertop
    psmisc
    ripgrep
    sysstat
    tmux
    tree
    usbutils # lsusb
    unzip
    wget

    # Desktop
    alsa-firmware
    alsa-tools
    colord
    feh
    gnupg
    libnotify
    maim
    openvpn
    pavucontrol
  ];

  environment.shellInit = ''
    export EDITOR=nvim
    export VISUAL=nvim
  '';

  fonts.packages = with pkgs; [
    noto-fonts
    dejavu_fonts

    corefonts # Needed for kerbal space program mods?

    # Not sure which of these we need, used to just get all of nerdfonts
    nerd-fonts.droid-sans-mono
    font-awesome
    powerline-fonts
  ];
  fonts.enableDefaultPackages = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # dnsmasq
  #services.dnsmasq.enable = true;
  #services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "2001:4860:4860::8844" "100.100.100.100" ];
  #networking.networkmanager.dns = "dnsmasq";

  networking.networkmanager.enable = true;
  networking.networkmanager.appendNameservers = [ "1.1.1.1" "8.8.8.8" "2001:4860:4860::8844" ];

  networking.hostName = hostname;
  networking.search = [ "shazow.gmail.com.beta.tailscale.net" ];
  #networking.resolvconf.dnsExtensionMechanism = false; # Remove edns0 option in resolv.conf: Breaks some public WiFi but it is required for DNSSEC.
  networking.networkmanager.wifi.backend = "iwd"; # "wpa_supplicant" is default
  networking.networkmanager.wifi.macAddress = lib.mkDefault "stable"; # One of "preserve", "random", "stable", "permanent", "00:11:22:33:44:55"
  networking.networkmanager.wifi.powersave = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Started on-demand by docker.socket
  };

  users.users.${primaryUsername} = {
    isNormalUser = true;
    home = "/home/${primaryUsername}";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev" "dialout" "adbusers" "docker" "i2c" "kvm" "libvirt" ];
    uid = 1000;
    initialHashedPassword = initialHashedPassword;
  };

  networking.firewall.checkReversePath = "loose"; # Workaround for tailscale? https://github.com/tailscale/tailscale/issues/3310
  # networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [];
  networking.nftables.enable = true;

  hardware.sane.enable = true;
  hardware.keyboard.zsa.enable = true;

  # programs.nix-ld.enable = true; # Run unpatched dynamic libraries
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  programs.dconf.enable = true; # Needed for GTK
  programs.light.enable = true;
  programs.gnupg.agent.enable = true; # GPG Daemon needed for pinentry
  programs.adb.enable = true; # Android dev
  services.geoclue2.enable = true;
  services.fwupd.enable = true;
  services.fstrim.enable = true; # for SSDs
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false; # FIXME: Workaround for systemd/dbus related issue? https://github.com/NixOS/nixpkgs/issues/180175
  # services.localtimed.enable = true; # Broken: https://github.com/NixOS/nixpkgs/issues/177792
  services.automatic-timezoned.enable = true; # Substitute for localtimed

  # Wireguard
  networking.wireguard.enable = true;
  networking.iproute2.enable = true; # Needed for mullvad daemon
  services.mullvad-vpn.enable = true;
  services.tailscale.enable = true;

  # Gaming and app wrapping (Steam)
  services.flatpak.enable = true;
  services.accounts-daemon.enable = true; # Required for flatpak+xdg
  xdg.portal.enable = true; # xdg portal is used for tunneling permissions to flatpak
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "*";
  xdg.portal.wlr.enable = true;

  security.polkit.enable = true;
  security.rtkit.enable = true; # Real time scheduling support, useful for audio priority
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Not sure if Steam still needs this
    pulse.enable = true; # Pulse server emulation, useful for running pulseaudio GUIs
  };
}
