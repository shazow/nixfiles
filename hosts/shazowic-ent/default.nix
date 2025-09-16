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
    ../../home/desktop-niri.nix
  ];

  root = import ./configuration.nix;
}
