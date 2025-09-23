# Wayland alternative to x11.nix
# TODO: Add https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit
{ pkgs, config, lib, pkgs-unstable, ... }:
let
  lockcmd = "${pkgs.swaylock}/bin/swaylock";
  term = "alacritty"; # TODO: Plumb this
in
{
  imports = [
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    xwayland-satellite
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
    settings = import ../config/niri.nix { inherit pkgs config lockcmd term; };
  };

  # TODO: Try https://github.com/abenz1267/walker? 
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "yes";
        width = "100";
      };
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = lockcmd; }
      { event = "lock"; command = lockcmd; }
    ];
    timeouts = [
      # Turn off screen (just before locking)
      {
        timeout = 170;
        command = "${pkgs.wlr-randr}/bin/wlr-randr --output '*' --off";
        resumeCommand = "${pkgs.wlr-randr}/bin/wlr-randr --output '*' --on";
      }
      # Lock computer
      {
        timeout = 180;
        command = lockcmd;
      }
    ];
  };
}
