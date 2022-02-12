{ pkgs, config, ... }:

let 
  # Package up local script binaries
  localScripts = map (name: pkgs.substituteAll {
      src = ../bin + "/${name}";
      dir = "bin";
      isExecutable = true;
    }) (builtins.attrNames (builtins.readDir ../bin));
in {
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
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      # Inject tree-sitters, since they're annoying to maintain with sideloading
      (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
    ];
    # We used to manage our own init.lua but now we want the home-manager
    # managed init.vim to load our init.lua which makes this a little dirty.
    extraConfig = ''
    lua << EOF
    ${builtins.readFile ../config/nvim/init.lua}
    EOF
    '';
  };

  # Neovim configs semi-managed by home-manager (via symlinks)
  xdg.configFile = {
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

  home.packages = (with pkgs; [
    # Apps
    bitwarden
    google-chrome-beta
    i3status-rust

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
    (python3.withPackages(ps: with ps; [
      black
      ipython
      pipx
      pynvim # Must be included in withPackages for neovim to get access to it.
      python-lsp-server
      jedi
    ]))
    gcc
    go
    gopls
    stylua # lua formatter
    sumneko-lua-language-server # Lua lsp
    rnix-lsp # Nix lsp
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
    playerctl
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
    dconf
  ]) ++ localScripts; 
}
