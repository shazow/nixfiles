# References:
# - https://gitlab.com/rprospero/dotfiles/-/blob/master/flake.nix
# - https://github.com/dwf/dotfiles/blob/master/flake.nix
# - https://github.com/srid/nixos-config/blob/master/flake.nix
{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-${stateVersion}";
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/af21c31b2a1ec5d361ed8050edd0303c31306397.tar.gz";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
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

    homeConfigurations."shazow" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # TODO: Parameterize between portable.nix and desktop.nix, right now it's a symlink
        ./home/portable.nix
      ];
    };
  };
}
