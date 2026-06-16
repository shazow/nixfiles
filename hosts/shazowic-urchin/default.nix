{
  inputs,
  ...
}:
{
  system = "x86_64-linux";

  modules = [
    inputs.disko.nixosModules.disko
    ./disko.nix
  ];

  home = [
  ];

  root = ./configuration.nix;
}
