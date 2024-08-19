{
  inputs,
  ...
}:
{
  system = "x86_64-linux";

  modules = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  home = [
    ../../home/portable.nix
  ];

  root = ./configuration.nix;
}
