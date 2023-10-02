{ pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Desktop environment agnostic packages.
  environment.systemPackages = with pkgs; [
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
  ];

  environment.shellInit = ''
    export EDITOR=nvim
    export VISUAL=nvim
  '';

  fonts.fonts = with pkgs; [
    noto-fonts
    dejavu_fonts
    nerdfonts # Includes font-awesome, material-icons, powerline-fonts
    emojione
  ];
  fonts.enableDefaultFonts = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  # FIXME: Do we need this?
  # fonts.optimizeForVeryHighDPI = true; # Larger fonts in console

  #services.dnsmasq.enable = true;
  #services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "2001:4860:4860::8844" "100.100.100.100" ];
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "dnsmasq";
  networking.networkmanager.appendNameservers = [ "1.1.1.1" "8.8.8.8" "2001:4860:4860::8844" ];

  networking.firewall.checkReversePath = "loose"; # Workaround for tailscale? https://github.com/tailscale/tailscale/issues/4432
  # networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [];

  hardware.sane.enable = true;

  # programs.nix-ld.enable = true; # Run unpatched dynamic libraries
  programs.dconf.enable = true; # Needed for GTK
  programs.light.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.fstrim.enable = true; # for SSDs
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  systemd.services.NetworkManager-wait-online.enable = false; # FIXME: Workaround for systemd/dbus related issue? https://github.com/NixOS/nixpkgs/issues/180175
  # services.localtimed.enable = true; # Broken: https://github.com/NixOS/nixpkgs/issues/177792


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
  hardware.opengl.driSupport32Bit = true;

  security.rtkit.enable = true; # Real time scheduling support, useful for audio priority
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Not sure if Steam still needs this
    pulse.enable = true; # Pulse server emulation, useful for running pulseaudio GUIs
  };
}
