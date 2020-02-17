{ pkgs, ... }:

{
  # This setup for console-based login and automatic startx works with:
  #   services.xserver.displayManager.startx.enable = true;
  #   services.xserver.desktopManager.default = "none";

  # TODO: exec xcalib -d :0 "${nixpkgs}/hardware/thinkpad-x1c-hdr.icm"
  home.file.".xinitrc".text = ''
    # Delegate to xsession config
    . ~/.xsession
  '';

  home.file.".bash_profile".text = ''
    if [[ -f ~/.bashrc ]] ; then
      . ~/.bashrc
    fi
    if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
      exec ssh-agent startx --  -dpi 140
    fi
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

    # dbus-launch manages cross-process communication (required for GTK systray icons, etc).
    # FIXME: Is dbus-launch necessary now that it's part of xsession?
    windowManager.command = "dbus-launch --exit-with-x11 i3";

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

  services.dunst = {
    enable = true;
    settings = {
      global = {
        geometry = "600x5-30+20";
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        font = "DejaVu Sans Mono 10";
        format = "<b>%s</b>\n%b";
        icon_position = "left";
        max_icon_size = 48;

        dmenu = "rofi -dmenu -p Dunst";
        browser = "xdg-open";
      };
      shortcuts = {
        close = "ctrl+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };
    };
  };
}
