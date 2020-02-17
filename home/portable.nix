{ pkgs, ... }:

let i3statusCfg = import ./common/i3status-rust.nix;
in
{
  imports = [
    ./common/apps.nix
    ./common/x11.nix
  ];

  # External monitor management
  programs.autorandr = import ./config/autorandr.nix;

  home.file.".config/i3/config".source = ./config/i3/config;
  home.file.".config/i3/status.toml".text = ''
    ${i3statusCfg.head}
    ${i3statusCfg.laptop}
    ${i3statusCfg.tail}
  '';
}
