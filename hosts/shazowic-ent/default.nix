{
  inputs,
  ...
}:
{
  system = "x86_64-linux";

  modules = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd

    ../../modules/bootlayout.nix
  ];

  home = [
    ../../home/desktop.nix

    {
      services.easyeffects.enable = true;

      # Not sure if I like this EQ, need to experiment more
      #services.easyeffects.preset = "Sennheiser-HD6XX-easyeffects"; # keys from easyeffects/output/*.json
      xdg.configFile."easyeffects/output/HD6XX.json".source = ../../hardware/Sennheiser-HD6XX-oratory1990-easyeffects.json;
    }
  ];

  root = import ./configuration.nix;
}
