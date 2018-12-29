{ pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  environment.systemPackages = with pkgs; [
    neovim
    gnumake
  ];

  networking.networkmanager.enable = true;
  services.sshd.enable = true;
}
