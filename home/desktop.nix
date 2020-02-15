{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  # This is backported from x11.nix

  home.file.".bash_profile".text = ''
    if [[ -f ~/.bashrc ]] ; then
      . ~/.bashrc
    fi
  ''

  home.file.".config/i3/status.toml".source = ../config/i3/status.toml;

  gtk = {
    enable = true;
    theme = {
      package = pkgs.theme-vertex;
      name = "Vertex-Dark";
    };
    iconTheme = {
      package = pkgs.tango-icon-theme;
      name = "Tango";
    };
  };

  imports = [
    #./common/x11.nix
    ./common/apps.nix
  ];
}
