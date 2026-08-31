{
  inputs.microvm = {
    url = "github:astro/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      microvm,
    }:
    let
      system = "x86_64-linux";
      name = "shell-example";
      shellExample = import ./. { inherit microvm nixpkgs system; };
    in
    {
      packages.${system} = {
        default = self.packages.${system}.${name};
        "${name}" = shellExample.config.microvm.declaredRunner;
      };

      nixosConfigurations.${name} = shellExample;
    };
}
