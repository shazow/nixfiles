{ username, inputs, ... }:

{
  imports = [
    ./common/wayland.nix
    ./common/wayland-niri.nix
    ./common/wayland-sway.nix # TODO: Remove
    ./common/apps.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "25.05";
}
