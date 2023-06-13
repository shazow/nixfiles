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

  outputs = { nixpkgs, home-manager, ... }: let
    devices = import ./devices.nix;
  in {

    inherit devices;

    # NixOS System Configuration generator
    # Called by a device flake, can be generated from templates/nixos-device

    mkSystemConfigurations = {
      devices,
      hashedPassword, # Used for passwd
    }: builtins.mapAttrs (name: device: nixpkgs.lib.nixosSystem {
      system = device.system;
      modules = device.modules ++ [
        home-manager.nixosModules.home-manager
        {
          # https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module
          home-manager.useUserPackages = true;
          home-manager.useGlobalPkgs = true;
        }
      ];
      specialArgs = {
        inherit hashedPassword;
      };
    }) devices;

    # Homes:
    # We generate a "username@hostname" combo per device

    homeConfigurations = nixpkgs.lib.attrsets.mapAttrs' (name: device: {
      name = "shazow@${name}";
      value = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${device.system};
        modules = device.home + [
          # FIXME: Workaround. Remove when fixed:
          # - https://github.com/nix-community/home-manager/issues/2942
          # - https://github.com/NixOS/nixpkgs/issues/171810
          { nixpkgs.config.allowUnfreePredicate = (pkg: true); }
        ];
      };
    }) devices;

  };
}
