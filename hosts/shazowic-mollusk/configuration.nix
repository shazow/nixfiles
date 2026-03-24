{
  pkgs,
  lib,
  initialHashedPassword,
  ...
}: let
  primaryUsername = "agent";
in {
  imports = [
    ./hardware.nix
    ../../modules/users.nix
  ];

  nixfiles.users = {
    enable = true;
    inherit initialHashedPassword primaryUsername;
  };

  networking.hostName = "shazowic-mollusk";

  # Synology-hosted VM defaults
  services.qemuGuest.enable = true;

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  users.users.${primaryUsername}.extraGroups = lib.mkAfter [ "docker" ];

  environment.systemPackages = with pkgs; [
    git
    tmux
    uv
  ];

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "25.11";
}
