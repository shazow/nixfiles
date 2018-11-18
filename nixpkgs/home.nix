{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    # system utils
    htop
    psmisc
    binutils-unwrapped
    acpi
    sysstat
    lm_sensors
    fwupd
    p7zip
    unzip

    # user utils
    imagemagick
    gnupg

    # languages & build tools
    go
    gnumake
    gcc
    tokei
    python
    python3
    cmake
    nodejs-10_x
    ms-sys

    # desktop env
    i3status-rust
    i3lock
    maim
    pavucontrol
    feh
    libnotify

    # apps
    appimage-run
    google-chrome
    alacritty
    pcmanfm

    # chat
    discord
    signal-desktop
  ];

  programs.home-manager = {
    enable = true;
    path = "https://github.com/rycee/home-manager/archive/release-18.03.tar.gz";
  };

  xsession = {
    enable = true;
    # TODO: windowManager.i3 = import ./i3.nix pkgs;
  };

  # TODO: programs.rofi = import ./rofi.nix pkgs;
  # TODO: services.dunst = import ./dunst.nix pkgs;
}
