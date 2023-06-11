# References:
# - https://gitlab.com/rprospero/dotfiles/-/blob/master/flake.nix
# - https://github.com/dwf/dotfiles/blob/master/flake.nix
# - https://github.com/srid/nixos-config/blob/master/flake.nix
let
  stateVersion = "23.05";
in
{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-${stateVersion}";
    nixpkgs.url = "github.com:NixOS/nixpkgs/archive/af21c31b2a1ec5d361ed8050edd0303c31306397";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-${stateVersion}";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    # Devices

    nixosConfigurations."shazowic-corvus" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./shazowic-corvus.nix
      ];
    };
    nixosConfigurations."shazowic-beast" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./shazowic-beast.nix
      ];
    };
    nixosConfigurations."shazowic-ghost" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./shazowic-ghost.nix
      ];
    };

    # Homes

    homeConfigurations."shazowic-corvus" = home-manager.lib.homeManagerConfiguration {
      modules = [
        ./home/portable.nix
      ];
    };
    homeConfigurations."shazowic-beast" = home-manager.lib.homeManagerConfiguration {
      modules = [
        ./home/desktop.nix
      ];
    };
  };
}
