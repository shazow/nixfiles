let
  mozilla = import (builtins.fetchGit {
    url = "https://github.com/mozilla/nixpkgs-mozilla.git";
    ref = "master";
    rev = "37f7f33ae3ddd70506cd179d9718621b5686c48d"; # 2019-02-12
  })
; in

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

    # Progamming
    ctags
    python3
    gcc
    go
    nodejs-10_x

    # Programming: Rust
    latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    rustracer
    cargo-edit

    obs-studio # Screen recording, stremaing
    transmission-gtk # Torrents

    vlc

    # TODO: Move these to system config?
    file
    jq
    powerstat
    #tlp
    xorg.xkill
  ];

}
