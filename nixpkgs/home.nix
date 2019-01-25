{ pkgs, ... }:

{
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

    obs-studio # Screen recording, stremaing
    transmission-gtk # Torrents

    # TODO: Move these to system config?
    file
    jq
    powerstat
    xorg.xkill
  ];

}
