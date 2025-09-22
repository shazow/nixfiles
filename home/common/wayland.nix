# Wayland alternative to x11.nix
# TODO: Add https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit
{ pkgs, config, lib, pkgs-unstable, ... }:
let
  term = "alacritty";
  sessionVars = {
    GDK_BACKEND = "wayland"; # GTK
    XDG_SESSION_TYPE = "wayland"; # Electron
    QT_QPA_PLATFORM = "wayland"; # QT

    # Electron apps should use Ozone/wayland
    NIXOS_OZONE_WL = "1";
    TERMINAL=term;
  };

  lockcmd = "${pkgs.swaylock}/bin/swaylock -fF";
in
{
  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
  };

  home.sessionVariables = sessionVars;

  home.packages = with pkgs; [
    wdisplays
    wl-mirror
  ];

  gtk.enable = true;

  services.gammastep = {
    enable = true;
    tray = true;
    provider = "geoclue2";
    temperature.day = 5700;
    temperature.night = 3500;
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = lib.mkDefault "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  services.mako.enable = true;
  services.mako.settings.default-timeout = 3000;
  services.cliphist.enable = true;
  services.network-manager-applet.enable = true;

  programs.wezterm = {
    enable = true;
    extraConfig = # lua
    ''
      return {
        scrollback_lines = 10000,
      }
    '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      colors.primary.background = lib.mkDefault "#000000";
      env.TERM = "xterm-256color"; # ssh'ing into old servers with TERM=alacritty is sad
    };
  };

  stylix = {
    enable = true;
    polarity = "dark";
    # https://github.com/tinted-theming/schemes
    # https://tinted-theming.github.io/tinted-gallery/
    # Some good candidates:
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-black.yaml";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/irblack.yaml";

    # Mylokai ported: https://github.com/shazow/dotfiles/blob/ac38d11e445b508f2578c05c5eff4be9d053b7c1/.vim/colors/mylokai.vim
    # base16Scheme = ((pkgs.formats.yaml {}).generate "mylokai.yaml" {
    #   base00 = "1B1D1E";
    #   base01 = "293739";
    #   base02 = "403D3D";
    #   base03 = "546568";
    #   base04 = "808080";
    #   base05 = "F8F8F2";
    #   base06 = "F8F8F0";
    #   base07 = "F9F8F5";
    #   base08 = "F92672";
    #   base09 = "FD971F";
    #   base0A = "E6DB74";
    #   base0B = "A6E22E";
    #   base0C = "66D9EF";
    #   base0D = "66D9EF";
    #   base0E = "AE81FF";
    #   base0F = "d56825";
    # }).outPath;
    # 
  };
}
