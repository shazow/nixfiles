{ pkgs, ... }:
{
  system.copySystemConfiguration = true;

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      neovim = pkgs.neovim.override {
        vimAlias = true;
      };
    };
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
    patchelf
    pciutils
    powertop
    psmisc
    ripgrep
    sysstat
    tmux
    tree
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
    terminus
    nerdfonts  # Includes font-awesome, material-icons, powerline-fonts
    emojione
  ];
  # TODO: Use fonts.enableDefaultFonts = true?

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  hardware.video.hidpi.enable = true; # Larger fonts in console

  networking.networkmanager.enable = true;
  # networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [];


  hardware.sane.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;

    # Need full for bluetooth support
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];

    daemon.config = {
      # Trying to fix crackling audio during gaming+mic
      default-sample-rate = 48000;

      # Other things to try:
      #flat-volumes = "no";
      #resample-method = "speex-float-10";
      #default-sample-format = "s16le";
      #default-fragments = 8;
      #default-fragment-size-msec = 10;
      #deferred-volume-safety-margin-usec = 1;
    };
  };

  programs.light.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

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

  sound.enable = true;
}
