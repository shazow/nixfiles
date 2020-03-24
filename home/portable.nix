{ pkgs, ... }:

let i3statusCfg = import ./common/i3status-rust.nix;
in
{
  imports = [
    ./common/apps.nix
    ./common/x11.nix
  ];

  # TODO: I think this can safely be removed now?
  xresources.properties = {
    "Xft.dpi" = 140; # = 210 / 1.5, where 210 is the native DPI.
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
