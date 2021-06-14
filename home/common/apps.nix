{ pkgs, config, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  programs.git.delta.enable = true;
  programs.alacritty = {
    enable = true;
    settings = {
      colors.primary.background = "#000000";
      env.TERM = "xterm-256color"; # ssh'ing into old servers with TERM=alacritty is sad
    };
  };

  # Neovim
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];
  xdg.configFile = {
    "nvim/init.lua".source = ../config/nvim/init.lua;
    "nvim/lua" = {
      source = config.lib.file.mkOutOfStoreSymlink ../config/nvim/lua;
      recursive = true;
    };
    # Older vim stuff that still needs to be migrated to lua
    "nvim/plugin/legacy.vim".source = config.lib.file.mkOutOfStoreSymlink ../config/nvim/plugin/legacy.vim;
  };

  home.file.".tmux.conf".source = ../config/tmux.conf;

  # Run `gpg-connect-agent reloadagent /bye` after changing to reload config
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry}/bin/pinentry
  '';

  home.packages = with pkgs; [
    # Apps
    google-chrome-beta
    i3status-rust
    neovim-nightly

    # Games
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
    (python38.withPackages(ps: with ps; [
      ipython
      pynvim # Must be included in withPackages for neovim to get access to it.
      jedi
      python-language-server
    ]))
    gcc
    go
    gopls
    nodejs_latest
    tree-sitter
    websocat # websocket netcat
    zeal

    # Programming: Rust
    #latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    #rustracer
    #cargo-edit

    drive # google drive cli
    obs-studio # Screen recording, stremaing
    transmission-gtk # Torrents

    #mplayer  # TODO: Switch to mpc?
    vlc

    srandrd # Daemon for detecting hotplug display changes, calls autorandr

    # TODO: Move these to system config?
    bat
    mdcat
    #delta
    file
    fzf
    gotop
    jq
    powerstat
    lsof
    hsetroot # for setting bg in picom (xsetroot doesn't work)
    xrandr-invert-colors
    xcwd # cwd of the current x window, tiny C program
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    whois

    # Needed for GTK
    gnome3.dconf
  ];
}
