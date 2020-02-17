{ pkgs, ... }:

{
  # This setup for console-based login and automatic startx works with:
  #   services.xserver.displayManager.startx.enable = true;
  #   services.xserver.desktopManager.default = "none";

  # TODO: exec xcalib -d :0 "${nixpkgs}/hardware/thinkpad-x1c-hdr.icm"
  home.file.".xinitrc".text = ''
    # dbus-launch manages cross-process communication (required for GTK systray icons, etc).
    exec dbus-launch --exit-with-x11 i3
  '';

  home.file.".bash_profile".text = ''
    if [[ -f ~/.bashrc ]] ; then
      . ~/.bashrc
    fi
    #if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    #  exec ssh-agent startx --  -dpi 140
    #fi
  '';

  home.file.".config/i3/config".source = ../config/i3/config;
  home.file.".config/i3/status.toml".source = ../config/i3/status.toml;

  gtk = {
    enable = true;
    theme = {
      package = pkgs.theme-vertex;
      name = "Vertex-Dark";
    };
    iconTheme = {
      package = pkgs.tango-icon-theme;
      name = "Tango";
    };
  };

  xsession = {
    enable = true;
    windowManager.command = "dbus-launch --exit-with-x11 i3";
    initExtra = "if [[ $DISPLAY || $XDG_VTNR -ne 1 ]]; then return 0; fi";

    pointerCursor = {
      name = "Vanilla-DMZ-AA";
      package = pkgs.vanilla-dmz;
      size = 32;
    };
  };

  # FIXME: Remove this in favour of fonts.fontconfig.dpi (not sure why that's
  # not sufficieny yet?)
  xresources.properties = {
    "Xft.dpi" = 140; # = 210 / 1.5, where 210 is the native DPI.
  };

  services.redshift = {
    enable = true;
    provider = "geoclue2";
    #provider = "manual";
    #latitude = "43.65";
    #longitude = "-79.38";
    temperature.day = 5700;
    temperature.night = 3500;
  };
}
