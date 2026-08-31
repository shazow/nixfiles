# Run any nixpkgs app as a QEMU graphical kiosk.
# Examples:
#   nix run .#foo
#   nix run .#chromium
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
      kiosks = import ./. { inherit microvm nixpkgs system; };
    in
    {
      legacyPackages.${system} = kiosks;

      # Default kiosk: chromium
      packages.${system}.default = self.legacyPackages.${system}.chromium;
    };
}
