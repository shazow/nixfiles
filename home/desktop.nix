{ pkgs, ... }:

let i3statusCfg = import ./common/i3status-rust.nix;
in
{
  programs.home-manager.enable = true;

  # External monitor management
  programs.autorandr = import ./config/autorandr.nix;

  home.packages = with pkgs; [
    firefox-beta-bin
    blender
  ];

  imports = [
    ./common/x11.nix
    ./common/apps.nix
  ];

  xresources.properties = {
    # Doesn't seem like most things need this, but flatpak electron apps do.
    "Xft.dpi" = 163; # 3840x2160 over 27"
  };

  home.file.".config/i3/config".source = ./config/i3/config;
  home.file.".config/i3/status.toml".text = ''
    ${i3statusCfg.head}
    ${i3statusCfg.tail}
  '';
}
