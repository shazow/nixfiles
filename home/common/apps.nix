{ pkgs, config, extrapkgs, ... }:
let
  # Package up local script binaries
  localScripts = map (name: pkgs.substituteAll {
      src = ../bin + "/${name}";
      dir = "bin";
      isExecutable = true;
    }) (builtins.attrNames (builtins.readDir ../bin));
in
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

  home.file.".tmux.conf".source = ../config/tmux.conf;

  # Run `gpg-connect-agent reloadagent /bye` after changing to reload config
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry}/bin/pinentry
  '';

  home.packages = (with pkgs; [
    extrapkgs.nvim.default

    # Apps
    bitwarden
    google-chrome-beta
    signal-desktop
    i3status-rust

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
    (python3.withPackages(ps: with ps; [
      black
      ipython
      pipx
      pynvim # Must be included in withPackages for neovim to get access to it.
      python-lsp-server
      jedi
    ]))
    gcc
    stylua # lua formatter
    sumneko-lua-language-server # Lua lsp
    rnix-lsp # Nix lsp
    nodejs_latest
    tree-sitter
    websocat # websocket netcat
    zeal

    # Gaming
    steam
    lutris
    wine

    # Programming: Rust
    #latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    #rustracer
    #cargo-edit
    go

    drive # google drive cli
    # obs-studio # Screen recording, streaming
    flameshot  # Screenshots
    transmission-gtk # Torrents
    mullvad-vpn # Frontend

    #mplayer  # TODO: Switch to mpc?
    playerctl
    vlc

    srandrd # Daemon for detecting hotplug display changes, calls autorandr

    # TODO: Move these to system config?
    bat
    mdcat
    #delta
    ddcutil
    file
    fzf
    gotop
    glib # for gsettings
    jq
    ncdu_2 # disk space analyzer
    powerstat
    lsof
    hsetroot # for setting bg in picom (xsetroot doesn't work)
    xrandr-invert-colors
    xcwd # cwd of the current x window, tiny C program
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    whois
  ]) ++ localScripts; 
}
