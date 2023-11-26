{ pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  services.greetd = {
    enable = true;
    default_session = {
      command = "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l";
    };
  };

  security.pam.services.swaylock = {};

  # TODO: programs.hyprland.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    extraPackages = with pkgs; [

      dbus-sway-environment
      configure-gtk
      wayland
      swaylock
      swayidle

      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      bemenu # wayland clone of dmenu
      j4-dmenu-desktop # enhances bemenu
      mako # notification system developed by swaywm maintainer
      wdisplays # tool to configure displays

      mako             # notification daemon
      redshift-wayland # patched to work with wayland gamma protocol # TODO: Replace with gammastep?

      wtype                  # xdotool, but for wayland
      xdg-desktop-portal-wlr # xdg-desktop-portal backend for wlroots

      xwayland
    ];
  };
}
