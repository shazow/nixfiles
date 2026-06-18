{
  pkgs,
  lib,
  initialHashedPassword,
  ...
}: let
  primaryUsername = "shazow";
  shazowGithubKeys = pkgs.fetchurl {
    url = "https://github.com/shazow.keys";
    hash = "sha256-nHKvVjTmTJM32hFEcdJ0bnNEV0ZEQThuuK8FW3YBdl8=";
  };
in {
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "shazowic-urchin";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
    initialHashedPassword = builtins.readFile "/tmp/initial-password";
    extraGroups = lib.mkAfter [ "wheel" "sudoers" "kvm" ];
    openssh.authorizedKeys.keyFiles = [ shazowGithubKeys ];
  };

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
  ];

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "26.05";
}
