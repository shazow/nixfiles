# This file might look a bit scary but really it's just some over-generalized
# transformers. (:
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Wayland desktop overlays
    niri-flake.url = "github:sodiboo/niri-flake";
    stylix.url = "github:nix-community/stylix/release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    # My old dotfiles
    dotfiles = { url = "github:shazow/dotfiles"; flake = false; };

    # Audio profiles for Framework 13 speakers
    # TODO: Inline the preset JSON we're using and get rid of this input, it's small and doesn't change.
    framework-audio-presets = { url = "github:ceiphr/ee-framework-presets"; flake = false; };
  };

  outputs = inputs@{ nixpkgs, home-manager, flake-utils, microvm, ... }:
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
            # Alternative way to access unstable packages inside pkgs.unstable.*
            #unstable = import nixpkgs-unstable {
            # inherit (final) system config;
            #};
          })
        ];
      };
    in rec
    {

      # NixOS System Configuration generator
      # Called by a device flake, can be generated from templates/nixos-device:
      #   nixosConfigurations = nixfiles.mkSystemConfigurations { ... }
      # We also use it below to generate VM configurations.

      mkSystemConfigurations =
        { primaryUsername ? username
        , initialHashedPassword ? null
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

      # VMs:
      vmConfigurations = mkSystemConfigurations {
        modules = [
          inputs.microvm.nixosModules.microvm
          ({ config, lib, pkgs, ... }: {
            nixfiles.bootlayout.enable = false;
            services.greetd.enable = lib.mkForce false;
            services.cage = {
              enable = true;
              program = "${pkgs.niri}/bin/niri-session"; # TODO: Unhardcode this
              user = username;
            };

            microvm = {
              mem = 4096;
              vcpu = 4;
              graphics.enable = true;

              hypervisor = "qemu";
              qemu.extraArgs = [
                # Handle fractal scaling on Wayland
                "-display" "sdl,gl=on"
              ];

              shares = [
                {
                  # 9p is slower than virtiofs but works in userland
                  proto = "9p";
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                  tag = "ro-store";
                }
              ];

              interfaces = [
                {
                  type = "user";
                  id = "microvm1";
                  mac = "02:02:00:00:00:01";
                }
              ];
            };
          })
        ];
      };

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
      {
        # Expose packages accessible on the flake
        # TODO: Consolidate with pkgsOverlayModule above?
        packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
          module.imports = [ ./pkgs/nvim/config ];
        };
        packages.vm = nixpkgs.legacyPackages.${system}.writeShellScriptBin "vm" ''
          exec nix run .#vmConfigurations."$HOSTNAME".config.microvm.declaredRunner
        '';
      }
    );
}
