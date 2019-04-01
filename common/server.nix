{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    gnumake
    git
  ];

  networking.networkmanager.enable = true;
  services.sshd.enable = true;
}
