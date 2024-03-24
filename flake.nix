# This flake is a shim for migrating my old non-flake NixOS config to a
# reproduceable flake. A lot of it involves inverting the call flow to allow
# for passing in all variable state from a root flake rather than sneaking them
# into the middle of the config stack.
#
# This file might look a bit scary but really it's just some over-generalized
# transformers. (:
#
# References:
# - https://gitlab.com/rprospero/dotfiles/-/blob/master/flake.nix
# - https://github.com/dwf/dotfiles/blob/master/flake.nix
# - https://github.com/srid/nixos-config/blob/master/flake.nix
{
  inputs = {
    # Flake registry defaults omitted:
    # - nixpkgs
    # - nixos-hardware
    # - home-manager

    # My nvim config as a standalone nvim distribution
    nvim.url = "path:./pkgs/nvim";
    nvim.inputs.nixpkgs.follows = "nixpkgs";

    # Framework embedded controller tool
    ectool.url = "github:tlvince/ectool.nix";
    ectool.inputs.nixpkgs.follows = "nixpkgs";

    # My old dotfiles
    dotfiles = { url = "github:shazow/dotfiles"; flake = false; };

    # Audio profiles for Framework 13 speakers
    framework-audio-presets = { url = "github:ceiphr/ee-framework-presets"; flake = false; };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, flake-utils, ... }: let
    username = "shazow";

    # Mappings from hostname to device configurations are derived from ./hosts/*.nix
    hosts = with nixpkgs.lib;
      mapAttrs' (
        name: value: {
          name = strings.removeSuffix ".nix" name;
          value = import ./hosts/${name} { inherit inputs; };
        }
      ) (builtins.readDir ./hosts);
  in {

    # NixOS System Configuration generator
    # Called by a device flake, can be generated from templates/nixos-device

    mkSystemConfigurations = {
      primaryUsername ? username,
      initialHashedPassword, # Used for passwd
    }: builtins.mapAttrs (hostname: host: nixpkgs.lib.nixosSystem {
      system = host.system;
      modules = host.modules ++ [
        host.root
        home-manager.nixosModules.home-manager
        {
          # https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module
          home-manager.useUserPackages = true;
          home-manager.useGlobalPkgs = true;
        }
      ];
      specialArgs = {
        inherit inputs hostname primaryUsername initialHashedPassword;
      };
    }) hosts;

    # Homes:
    # We generate a "username@hostname" combo per device

    homeConfigurations = nixpkgs.lib.attrsets.mapAttrs' (hostname: host: {
      name = "${username}@${hostname}";
      value = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          inherit inputs username hostname;
          extrapkgs = {
            nvim = inputs.nvim.defaultPackage.${host.system};
            ectool = inputs.ectool.defaultPackage.${host.system};
          };
        };
        pkgs = nixpkgs.legacyPackages.${host.system};
        modules = host.home ++ [
          # FIXME: Workaround. Remove when fixed:
          # - https://github.com/nix-community/home-manager/issues/2942
          # - https://github.com/NixOS/nixpkgs/issues/171810
          { nixpkgs.config.allowUnfreePredicate = (pkg: true); }
        ];
      };
    }) hosts;

    checks = {
      # Ensure all hosts have a `system` attribute
      system = builtins.all (builtins.attrValues hosts) (host: host.system != null);
    };

  } // flake-utils.lib.eachDefaultSystem (system:
    {
      packages.nvim = inputs.nvim.defaultPackage.${system};
    }
  );
}
