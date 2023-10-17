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
    nvim.url = "path:pkgs/nvim";
    nvim.inputs.nixpkgs.follows = "nixpkgs";
    dotfiles = {
      url = "github:shazow/dotfiles";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, nvim, dotfiles, ... }: let
    username = "shazow";
    devices = import ./devices.nix { inherit inputs; };
    defaultDisk = {
      # TODO: Generalize this somehow? Or remove to force overriding?
      efi = { device = "/dev/nvme0n1p1"; };
      luksDevices = {
        cryptswap = { device = "/dev/nvme0n1p2"; };
        cryptroot = { device = "/dev/nvme0n1p3"; };
      };
      extraFileSystems = {
      };
    };
  in {

    inherit devices;

    # NixOS System Configuration generator
    # Called by a device flake, can be generated from templates/nixos-device

    mkSystemConfigurations = {
      devices,
      initialHashedPassword, # Used for passwd
      disk ? defaultDisk, # Used for FDE
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
        inherit initialHashedPassword disk;
      };
    }) devices;

    # Homes:
    # We generate a "username@hostname" combo per device

    homeConfigurations = nixpkgs.lib.attrsets.mapAttrs' (hostname: device: {
      name = "${username}@${hostname}";
      value = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          inherit inputs username hostname;
          extrapkgs = {
            nvim = nvim.packages.${device.system};
          };
        };
        pkgs = nixpkgs.legacyPackages.${device.system};
        modules = device.home ++ [
          # FIXME: Workaround. Remove when fixed:
          # - https://github.com/nix-community/home-manager/issues/2942
          # - https://github.com/NixOS/nixpkgs/issues/171810
          { nixpkgs.config.allowUnfreePredicate = (pkg: true); }
        ];
      };
    }) devices;

  };
}
