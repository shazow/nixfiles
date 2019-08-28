let
  mozilla = import (builtins.fetchTarball {
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/50bae918794d3c283aeb335b209efd71e75e3954.tar.gz"; # master @ 2019-04-05
    sha256 = "07b7hgq5awhddcii88y43d38lncqq9c8b2px4p93r5l7z0phv89d";
  });
in

{ pkgs, ... }:

{
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    mozilla
  ];

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
    if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
      exec ssh-agent startx --  -dpi 140
    fi
  '';

  home.file.".config/i3/config".source = config/i3/config;
  home.file.".config/i3/status.toml".source = config/i3/status.toml;
  home.file.".tmux.conf".source = config/tmux.conf;

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

  home.packages = with pkgs; [
    # Games
    cataclysm-dda-git
    (dwarf-fortress.override {
      enableTWBT = true;
      enableTruetype = true;
      theme = "phoebus";
    })

    # PDF, image mainpulation
    ghostscript
    gimp
    qpdf
    xournal
    zathura
    #skanlite
    #simple-scan

    # Progamming
    ctags
    python3
    gcc
    go
    nodejs-10_x
    websocat # websocket netcat
    zeal

    # Programming: Rust
    #latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    #rustracer
    cargo-edit

    obs-studio # Screen recording, stremaing
    transmission-gtk # Torrents

    #mplayer  # TODO: Switch to mpc?
    vlc

    srandrd # Daemon for detecting hotplug display changes, calls autorandr

    # TODO: Move these to system config?
    file
    fzf
    gotop
    jq
    powerstat
    lsof
    #tlp
    xcwd # cwd of the current x window, tiny C program
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    pasystray
    whois

    # Needed for GTK
    gnome3.dconf
  ];

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

  xsession.pointerCursor = {
    name = "Vanilla-DMZ-AA";
    package = pkgs.vanilla-dmz;
    size = 32;
  };

  # External monitor management
  programs.autorandr = import ./autorandr.nix pkgs;
}
