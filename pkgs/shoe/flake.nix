{
  description = "shoe - FHS bubblewrap container for running";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      shoe = pkgs.callPackage ./. { };
    in
    {
      packages.${system}.default = shoe;

      apps.${system}.default = {
        type = "app";
        program = "${shoe}/bin/shoe";
      };
    };
}
