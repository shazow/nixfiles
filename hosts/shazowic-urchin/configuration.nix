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
  ];

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
    dates = "Tue *-*-* 04:00:00 America/New_York";
    persistent = true;
    allowReboot = true;
    runGarbageCollection = false;
  };

  nix.gc = {
    automatic = true;
    dates = "Thu *-*-* 04:00:00 America/New_York";
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "Thu *-*-* 04:00:00 America/New_York" ];
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
      # Keep SSH logins attached to a logind/PAM session so systemd --user
      # receives XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS.
      UsePAM = true;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.tailscale.enable = true;
  services.fstrim.enable = true;

  # Keep this small headless Intel box cooler/quieter while idle.
  services.thermald.enable = true;

  services.tuned = {
    enable = true;
    ppdSupport = false;
    recommend.powersave = { };
  };

  users.users.${primaryUsername} = {
    inherit initialHashedPassword;

    extraGroups = lib.mkAfter [
      "wheel"
      "sudoers"
      "kvm"
    ];
    isNormalUser = true;
    linger = true; # Keep the user manager/bus available for systemd --user over SSH.

    openssh.authorizedKeys.keyFiles = [ shazowGithubKeys ];
  };
  users.users."agent" = {
    extraGroups = lib.mkAfter [
      "kvm"
      "systemd-journal"
    ];
    isNormalUser = true;
    linger = true; # Need this for running systemd services without being logged in

    openssh.authorizedKeys.keyFiles = [ shazowGithubKeys ];
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

    lm_sensors

    home-manager
  ];

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "26.05";
}
