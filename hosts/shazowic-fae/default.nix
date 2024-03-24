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
  ];

  root = import ./configuration.nix;
}
