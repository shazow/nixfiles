{
  pkgs,
  lib,
  initialHashedPassword,
  ...
}:
let
  primaryUsername = "shazow";
  shazowGithubKeys = pkgs.fetchurl {
    url = "https://github.com/shazow.keys";
    hash = "sha256-nHKvVjTmTJM32hFEcdJ0bnNEV0ZEQThuuK8FW3YBdl8=";
  };
in
{
  imports = [
    ./hardware.nix
    ../../modules/users.nix
  ];

  nixfiles.users = {
    enable = true;
    inherit initialHashedPassword primaryUsername;
  };

  networking.hostName = "shazowic-urchin";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:shazow/nixfiles#shazowic-urchin";
    dates = "04:00";
    randomizedDelaySec = "45min";
    persistent = true;
    allowReboot = true;
    rebootWindow = {
      lower = "04:00";
      upper = "06:00";
    };
    runGarbageCollection = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    randomizedDelaySec = "1h";
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
    randomizedDelaySec = "1h";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024; # 8GB in MiB
    }
  ];

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.tailscale.enable = true;
  services.fstrim.enable = true;

  users.users.${primaryUsername} = {
    inherit initialHashedPassword;

    extraGroups = lib.mkAfter [
      "wheel"
      "sudoers"
      "kvm"
    ];
    isNormalUser = true;

    openssh.authorizedKeys.keyFiles = [ shazowGithubKeys ];
  };
  users.users."agent" = {
    extraGroups = lib.mkAfter [ "kvm" ];
    isNormalUser = true;
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ shazowGithubKeys ];

  environment.systemPackages = with pkgs; [
    curl
    fd
    git
    htop
    jq
    lsof
    neovim
    ripgrep
    tmux
    uv
    wget
    gnumake

    home-manager
  ];

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "26.05";
}
