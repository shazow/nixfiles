{ pkgs, pkgs-unstable, lib, hostname, primaryUsername, initialHashedPassword, ... }:
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

  imports = [
    ../modules/virtiofsd-nix-store.nix
  ];

  nixfiles.virtiofs-nix-store.enable = true;

  # Turn off screen after 60s in console
  boot.kernelParams = [ "consoleblank=60" ];

  boot.kernelModules = [
    "ntsync" # Used by wine/proton for more optimal Windows-based system lock/event primitives
  ];

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


  services.resolved = {
    enable = true;

    settings.Resolve = {
      FallbackDNS = [
        "1.1.1.1#one.one.one.one"
        "8.8.8.8#dns.google"
        "2606:4700:4700::1111#one.one.one.one"
      ];

      # A little sprinkle of sadness for dealing with rando wifi networks:
      DNSOverTLS = "opportunistic";
      DNSSEC = "allow-downgrade";
      MulticastDNS = false;
      LLMNR = false;
    };
  };

  networking.hostName = hostname;
  #networking.search = [ "shazow.gmail.com.beta.tailscale.net" ];

  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.networkmanager.wifi.backend = "iwd"; # Default: wpa_supplicant
  networking.networkmanager.wifi.scanRandMacAddress = true;
  networking.networkmanager.wifi.macAddress = lib.mkDefault "stable-ssid"; # One of "permanent", "preserve", "random", "stable", "stable-ssid", "00:11:22:33:44:55"
  networking.networkmanager.wifi.powersave = true;

  users.users.${primaryUsername} = {
    isNormalUser = true;
    home = "/home/${primaryUsername}";
    extraGroups = [ "wheel" "sudoers" "audio" "video" "disk" "networkmanager" "plugdev" "dialout" "docker" "i2c" "kvm" "libvirt" ];
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
  programs.nh.enable = true; # nix cli rewrite
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  programs.dconf.enable = true; # Needed for GTK
  programs.gnupg.agent.enable = true; # GPG Daemon needed for pinentry
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
      enable = lib.mkDefault true;
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
  services.mullvad-vpn.package = pkgs-unstable.mullvad;
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
  services.pipewire.wireplumber.extraConfig."51-disable-restore" = {
    "wireplumber.settings" = {
      # EasyEffects tends to overtake the real audio device as default device, which is annoying.
      "node.restore-default-targets" = false;
      "node.stream.restore-target" = false;

      # Disable even more things since the above is not enough:
      "device.restore-profile" = false;
      "device.restore-routes" = false;
      "node.stream.restore-props" = false;
    };
  };
}
