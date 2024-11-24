{
  inputs,
  ...
}:
{
  system = "x86_64-linux";

  modules = [
  ];

  home = [
    ../../home/portable.nix
  ];

  root = ./configuration.nix;
}

