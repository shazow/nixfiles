# Wayland alternative to x11.nix
# TODO: Add https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit
{ pkgs, config, lib, pkgs-unstable,
  portable ? false,
  ... }:
let
  lockcmd = "systemctl --user start lock.target";
  term = "alacritty"; # TODO: Plumb this
in
{
  imports = [
    ./ironbar.nix
  ];

  home.packages = with pkgs; [
    xwayland-satellite
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = import ../config/niri.nix {
      inherit pkgs config lockcmd term portable;
      bar = "ironbar";
    };
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
      { event = "lock"; command = lockcmd; }
      # FIXME: This should work with the systemctl lockcmd, but it doesn't for some reason? Not sure why. Try again later?
      # Bonu spoints if we can just use the systemd service directly to trigger on sleep reliably, so we don't need this part of swayidle
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
    ];
    timeouts = [
      # Turn off screen (just before locking)
      {
        timeout = 170;

        # Generic wayland:
        #command = "${pkgs.wlr-randr}/bin/wlr-randr --output '*' --off";
        #resumeCommand = "${pkgs.wlr-randr}/bin/wlr-randr --output '*' --on";

        # Niri specific:
        command = "niri msg action power-off-monitors";
        resumeCommand = "niri msg action power-on-monitors";
      }
      # Lock computer
      {
        timeout = 180;
        command = lockcmd;
      }
    ];
  };
}
