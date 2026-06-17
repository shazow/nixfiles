{ username, inputs, ... }:

{
  imports = [
    ./modules/wayland
    ./common/apps.nix
  ];

  nixfiles.wayland.enable = true;

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "26.05";
}
