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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # TODO: Switch back to normal nixos-unstable after https://nixpk.gs/pr-tracker.html?pr=446271 is built
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Wayland desktop overlays
    niri-flake.url = "github:sodiboo/niri-flake";
    stylix.url = "github:nix-community/stylix/release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Framework embedded controller tool
    # TODO: Remove this? Should be native in the kernel now
    ectool.url = "github:tlvince/ectool.nix";
    ectool.inputs.nixpkgs.follows = "nixpkgs";

    # My old dotfiles
    dotfiles = { url = "github:shazow/dotfiles"; flake = false; };

    # Audio profiles for Framework 13 speakers
    framework-audio-presets = { url = "github:ceiphr/ee-framework-presets"; flake = false; };

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ nixpkgs, home-manager, flake-utils, ... }:
    let
      username = "shazow";

      # Mappings from hostname to device configurations are derived from ./hosts/*.nix
      hosts = with nixpkgs.lib;
        mapAttrs'
          (
            name: value: {
              name = strings.removeSuffix ".nix" name;
              value = import ./hosts/${name} { inherit inputs; };
            }
          )
          (builtins.readDir ./hosts);

      pkgsOverlayModule = {
        nixpkgs.overlays = [
          inputs.niri-flake.overlays.niri

          (import ./pkgs/overlay.nix)

          # Extra packages we're injecting from inputs
          (final: prev: {
            # TODO: Move these into ./pkgs/overlay.nix?
            nvim = inputs.nixvim.legacyPackages.${prev.system}.makeNixvimWithModule {
              module.imports = [ ./pkgs/nvim/config ];
            };
            ectool = inputs.ectool.defaultPackage.${prev.system};
            # Alternative way to access unstable packages inside pkgs.unstable.*
            #unstable = import nixpkgs-unstable {
            # inherit (final) system config;
            #};
          })
        ];
      };
      # NixOS System Configuration generator
      # Called by a device flake, can be generated from templates/nixos-device

      mkSystemConfigurations =
        { primaryUsername ? username
        , initialHashedPassword
        , modules ? []
        , extraArgs ? {}
        ,
        }: builtins.mapAttrs
          (hostname: host: nixpkgs.lib.nixosSystem {
            system = host.system;
            modules = host.modules ++ [
              host.root
              pkgsOverlayModule
              home-manager.nixosModules.home-manager
              {
                # https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module
                home-manager.useUserPackages = true;
                home-manager.useGlobalPkgs = true;
              }
            ] ++ modules;
            specialArgs = {
              inherit inputs hostname primaryUsername initialHashedPassword;
            } // extraArgs;
          })
          hosts;
    in
    {
      inherit mkSystemConfigurations;

      nixosConfigurations = (mkSystemConfigurations {
        initialHashedPassword = "";
      }) // (nixpkgs.lib.attrsets.mapAttrs'
        (name: value: nixpkgs.lib.attrsets.nameValuePair "${name}-vm" value)
        (mkSystemConfigurations {
          initialHashedPassword = "";
          modules = [
            inputs.microvm.nixosModules.microvm
            ({ config, lib, ... }: {
              # Allow unfree packages
              nixpkgs.config.allowUnfree = true;

              # MicroVM configuration
              microvm = {
                hypervisor = "qemu";
                mem = 4096;
                vcpu = 2;

                shares = [
                  {
                    source = "/nix/store";
                    mountPoint = "/nix/.ro-store";
                    tag = "ro-store";
                    proto = "virtiofs";
                  }
                  {
                    source = "/var/lib/microvm/${config.networking.hostName}/share";
                    mountPoint = "/share";
                    tag = "share";
                    proto = "virtiofs";
                  }
                ];

                interfaces = [
                  {
                    type = "user";
                    id = "vm-net";
                    mac = "02:00:00:00:00:01";
                  }
                ];
              };

              # Networking setup for VM
              networking.useDHCP = false;
            })
          ];
        })
      );

      # Homes:
      # We generate a "username@hostname" combo per device

      homeConfigurations = nixpkgs.lib.attrsets.mapAttrs'
        (hostname: host: {
          name = "${username}@${hostname}";
          value = home-manager.lib.homeManagerConfiguration {
            extraSpecialArgs = {
              inherit inputs username hostname;
              pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
            };
            pkgs = nixpkgs.legacyPackages.${host.system};
            modules = host.home ++ [
              pkgsOverlayModule
              inputs.niri-flake.homeModules.niri
              inputs.stylix.homeModules.stylix
            ];
          };
        })
        hosts;

      checks = {
        # Ensure all hosts have a `system` attribute
        system = builtins.all (builtins.attrValues hosts) (host: host.system != null);
      };

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Expose packages accessible on the flake
        # TODO: Consolidate with pkgsOverlayModule above?
        packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
          module.imports = [ ./pkgs/nvim/config ];
        };

        packages.vm = pkgs.writeShellScriptBin "vm" ''
          host=$(uname -n)
          exec nix run .#nixosConfigurations."$host"-vm.config.microvm.declaredRunner
        '';
      }
    );
}
