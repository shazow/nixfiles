let
  mozilla = import (builtins.fetchTarball {
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/50bae918794d3c283aeb335b209efd71e75e3954.tar.gz"; # master @ 2019-04-05
    sha256 = "07b7hgq5awhddcii88y43d38lncqq9c8b2px4p93r5l7z0phv89d";
  });
in

{ pkgs, ... }:

{

  nixpkgs.overlays = [
    mozilla
  ];

  programs.home-manager.enable = true;
  services.redshift = {
    enable = true;
    provider = "geoclue2";
    #provider = "manual";
    #latitude = "43.65";
    #longitude = "-79.38";
    temperature.day = 5700;
    temperature.night = 3500;
  };

  nixpkgs.config.allowUnfree = true;
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
    zeal

    # Programming: Rust
    latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    rustracer
    cargo-edit

    obs-studio # Screen recording, stremaing
    transmission-gtk # Torrents

    #mplayer  # TODO: Switch to mpc?
    #vlc

    # TODO: Move these to system config?
    file
    fzf
    jq
    powerstat
    #tlp
    xorg.xkill
    xorg.xev
    pasystray
  ];

}
