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

    devices = import ./devices;

    mkSystemConfigurations = {
      devices,
      hashedPassword ? "", # Used for passwd
    }: builtins.mapAttrs (name: device: {
      inherit (device) system modules;
      specialArgs = {
        inherit hashedPassword;
      };
    }) devices;

    # Homes

    homeConfigurations."shazow" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # FIXME: Workaround. Remove when fixed:
        # - https://github.com/nix-community/home-manager/issues/2942
        # - https://github.com/NixOS/nixpkgs/issues/171810
        { nixpkgs.config.allowUnfreePredicate = (pkg: true); }


        # TODO: Parameterize between portable.nix and desktop.nix, right now it's a symlink
        ./home/portable.nix
      ];
    };
  };
}
