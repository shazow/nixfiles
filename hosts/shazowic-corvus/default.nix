{
  inputs,
  ...
}:
{
  system = "x86_64-linux";

  modules = [
    ../../modules/bootlayout.nix
  ];

  home = [
    ../../home/portable.nix
  ];

  root = ./configuration.nix;
}

