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
      browserKiosk = import ./. { inherit microvm nixpkgs system; };
    in
    {
      packages.${system} = {
        default = self.packages.${system}.browser-kiosk;
        browser-kiosk = browserKiosk.config.microvm.declaredRunner;
      };

      nixosConfigurations.browser-kiosk = browserKiosk;
    };
}
