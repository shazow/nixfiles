{ pkgs, ... }:

let i3statusCfg = import ./common/i3status-rust.nix;
in
{
  programs.home-manager.enable = true;

  imports = [
    ./common/x11.nix
    ./common/apps.nix
  ];

  home.file.".config/i3/config".source = ./config/i3/config;
  home.file.".config/i3/status.toml".text = ''
    ${i3statusCfg.head}
    ${i3statusCfg.tail}
  '';
}
