{
  inputs,
  ...
}:
{
  system = "x86_64-linux";

  modules = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ../../modules/bootlayout.nix
  ];

  home = [
    ../../home/portable.nix

    {
      xresources.properties = {
        "Xft.dpi" = 256; # 2880x1920 over 13.5 screen (2.8K panel)
      };

      wayland.windowManager.sway.config.output."eDP-1" = {
        adaptive_sync = "on";
        scale = "1.75";
      };

      # Speaker calibration
      services.easyeffects.enable = true;
      services.easyeffects.preset = "kieran_levin"; # keys from easyeffects/output/*.json
      xdg.configFile."easyeffects/output".source = inputs.framework-audio-presets.outPath;
    }
  ];

  root = ./configuration.nix;
}
