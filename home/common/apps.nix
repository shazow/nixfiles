let
  mozilla = import (builtins.fetchTarball {
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/50bae918794d3c283aeb335b209efd71e75e3954.tar.gz"; # master @ 2019-04-05
    sha256 = "07b7hgq5awhddcii88y43d38lncqq9c8b2px4p93r5l7z0phv89d";
  });
in

{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    mozilla
  ];

  home.file.".tmux.conf".source = ../config/tmux.conf;

  # Run `gpg-connect-agent reloadagent /bye` after changing to reload config
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry}/bin/pinentry
  '';

  home.packages = with pkgs; [
    # Apps
    alacritty
    google-chrome-beta
    firefox-beta-bin

    # Games
    cataclysm-dda-git
    (dwarf-fortress.override {
      enableTWBT = true;
      enableTruetype = true;
      theme = "phoebus";
    })
    wesnoth

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
    curlie
    python3
    python37Packages.ipython
    python37Packages.pynvim
    gcc
    go
    nodejs-10_x
    websocat # websocket netcat
    zeal

    # Programming: Rust
    #latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    #rustracer
    #cargo-edit

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
    xrandr-invert-colors
    xcwd # cwd of the current x window, tiny C program
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    pasystray
    whois

    # Needed for GTK
    gnome3.dconf
  ];
}
