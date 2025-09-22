{ pkgs, pkgs-unstable, inputs, ... }:
let
  # Package up local script binaries
  bundleScripts = name: src: pkgs.stdenv.mkDerivation {
    inherit name src;

    installPhase = ''
      mkdir -p $out/bin
      cp -r $src/* $out/bin/
    '';
  };

  localScripts = bundleScripts "localScripts" ../bin;
  dotfileScripts = bundleScripts "dotfileScripts" "${inputs.dotfiles.outPath}/local/bin";
in
{
  nixpkgs.config.allowUnfree = true;

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
      difftastic.enable = true;
      userName = "Andrey Petrov";
      userEmail = "andrey.petrov@shazow.net";
      aliases = {
        undo = "reset --soft HEAD^";
        last = "log -1 HEAD";
        serve = "daemon --reuseaddr --base-path=. --export-all --verbose --enable=receive-pack --listen=0.0.0.0";
        remote-add-me = ''
          !remote-add() {
            git remote add shazow "git@github.com:shazow/$1";
          };
          remote-add $(basename $(git remote get-url origin))
        '';

        diff2 = "diff --color-words --ignore-all-space --patience";
        log2 = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";

        deploy = "!merge(){ git checkout $2 && git merge $1 && git push $2 && git checkout \${1#refs/heads/}; }; merge $(git symbolic-ref HEAD) $1";
        blast = ''for-each-ref --sort=-committerdate refs/heads/ --format="%(committerdate:relative)%09%(refname:short)"'';
        pr = "!pr(){ git fetch origin pull/$1/head:pr-$1; git checkout pr-$1; }; pr";

        # Interactive
        ilog = "!git log --oneline --color=always | fzf --ansi --reverse --preview='git show --color=always {1}'";
        ibranchlog = "!git log --color=always --oneline $(git merge-base main HEAD)..HEAD | fzf --ansi --reverse --preview='git show --color=always {1}'";
      };
      extraConfig = {
        push = { autoSetupRemote = true; };
        init.defaultBranch = "main";
      };
    };

    bash = {
      enable = true;
      initExtra = ''
        # Load machine-local settings
        [[ -f ~/.bash_private ]] && source ~/.bash_private

        # -- dotfiles/helpers.bash
        ${builtins.readFile "${inputs.dotfiles.outPath}/helpers.bash"}

        # -- dotfiles/.bash_profile
        ${builtins.readFile "${inputs.dotfiles.outPath}/.bash_profile"}
      '';
    };
  };

  services.gpg-agent = {
    # Run `gpg-connect-agent reloadagent /bye` after changing to reload config
    enable = true;
  };
  
  fonts.fontconfig.enable = true; # Auto-discover fonts

  home.file.".tmux.conf".source = ../config/tmux.conf;

  home.packages = [
    localScripts
    dotfileScripts
  ] ++ (with pkgs; [
    # Some extrapkgs are duplicated from system packages for more frequent
    # updates in userland
    nvim

    # Apps
    bitwarden
    google-chrome
    signal-desktop

    # PDF, image mainpulation
    ghostscript
    gimp
    qpdf
    #xournalpp
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
    nodejs_latest
    tree-sitter
    websocat # websocket netcat
    zeal
    nix-doc
    nix-output-monitor

    # Gaming
    lutris
    wine
    # prismlauncher # minecraft launcher
    #umu-launcher # TODO: Uncomment when https://github.com/NixOS/nixpkgs/pull/369259 is merged

    # Programming: Rust
    #latest.rustChannels.nightly.rust
    #latest.rustChannels.nightly.rust-src  # Needed for $RUST_SRC_PATH?
    #rustracer
    #cargo-edit
    go

    rclone
    gocryptfs # Encrypted volumes
    # obs-studio # Screen recording, streaming
    grim # Wayland screenshot backend?
    (pkgs-unstable.flameshot.override { enableWlrSupport = true; }) # Screenshots
    transmission_4-gtk # Torrents
    mullvad-vpn # Frontend

    #mplayer  # TODO: Switch to mpc?
    playerctl
    vlc

    srandrd # Daemon for detecting hotplug display changes, calls autorandr

    # TODO: Move these to system config?
    bat
    blueberry # gtk bluetooth frontend
    mdcat
    ddcutil
    file
    fzf
    gotop
    glib # for gsettings
    gsettings-desktop-schemas
    impala # wifi tui, like nmtui
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

    # Fonts
    dejavu_fonts
    font-awesome_4
    material-icons
    powerline-fonts
  ]);
}
