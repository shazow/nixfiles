{ username, inputs, ... }:

{
  imports = [
    ./common/wayland-sway.nix
    ./common/apps.nix
  ];

  # External monitor management
  programs.autorandr = import ./config/autorandr.nix;

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "25.05";
}
