{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./common/x11.nix
    ./common/apps.nix
  ];

  services.openssh = {
    enable = true;
    startWhenNeeded = true;  # Don't start until socket request comes in to systemd
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };
}
