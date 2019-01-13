{ pkgs, ... }:
{
  imports = [
    # Only needed for 18.09 and older:
    # ../backports/startx.nix
  ];

  # FIXME: Is this necessary?
  system.copySystemConfiguration = true;

  nixpkgs.config.allowUnfree = true;
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
    fwupd
    git
    gnumake
    htop
    lm_sensors
    mkpasswd
    neovim
    p7zip
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
    dejavu_fonts
    terminus
    nerdfonts  # Includes font-awesome, material-icons, powerline-fonts
  ];

  i18n = {
    consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  networking.networkmanager.enable = true;
  # networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [];

  hardware.pulseaudio.enable = true;
  programs.light.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.enable = true;

  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

  # Gaming (Steam)
  services.flatpak.enable = true;
  services.flatpak.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  sound.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";
    libinput.enable = true;
  };
}
