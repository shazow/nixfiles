args@{ config, lib, pkgs, pkgs-unstable, ... }:
let
  cfg = config.nixfiles.wayland;
  moduleArgs = args // {
    inherit config lib pkgs pkgs-unstable;
  };
in
{
  options.nixfiles.wayland = {
    enable = lib.mkEnableOption "Wayland desktop home configuration";

    desktop = lib.mkOption {
      type = lib.types.enum [ "niri" "sway" ];
      default = "niri";
      description = "Wayland desktop compositor to enable.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Swaylock systemd service lives here
    (import ./lock.nix moduleArgs)

    (import ./common.nix moduleArgs)

    (lib.mkIf (cfg.desktop == "niri") (lib.mkMerge [
      (import ../../common/ironbar.nix moduleArgs)
      (import ./niri.nix moduleArgs)
    ]))

    (lib.mkIf (cfg.desktop == "sway") (import ./sway.nix moduleArgs))
  ]);
}
