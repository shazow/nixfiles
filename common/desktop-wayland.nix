{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty"; 
      startup = [
        # Launch Firefox on start
        {command = "firefox";}
      ];
    };
  };


  services.greetd = {
    enable = true;
    default_session = {
      command = "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l";
    };
  };

  programs.sway = {
    enable = true;

    extraPackages = with pkgs; [

      dbus-sway-environment
      configure-gtk
      wayland
      swaylock
      swayidle

      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      bemenu # wayland clone of dmenu
      mako # notification system developed by swaywm maintainer
      wdisplays # tool to configure displays


      bemenu           # dmenu for sway
      j4-dmenu-desktop # enhances bemenu

      grim             # screen image capture
      mako             # notification daemon
      redshift-wayland # patched to work with wayland gamma protocol
      slurp            # screen area selection tool

      swaybg   # required by sway for controlling desktop wallpaper
      swayidle # used for controlling idle timeouts and triggers (screen locking, etc)
      swaylock # used for locking Wayland sessions

      wf-recorder            # wayland screenrecorder
      wl-clipboard           # clipboard CLI utilities
      wtype                  # xdotool, but for wayland
      xdg-desktop-portal-wlr # xdg-desktop-portal backend for wlroots

      xwayland
    ];

    extraSessionCommands = ''
      export GDK_BACKEND=wayland
    '';
  };
}
