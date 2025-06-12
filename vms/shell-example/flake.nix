{
  inputs.microvm = {
    url = "github:astro/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, microvm }: let
    system = "x86_64-linux";
    name = "shell-example";
  in {
    packages.${system} = {
      default = self.packages.${system}.${name};
      "${name}" = self.nixosConfigurations.${name}.config.microvm.declaredRunner;
    };

    nixosConfigurations = {
      "${name}" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          microvm.nixosModules.microvm
          {
            microvm = {
              mem = 1024;
              storeOnDisk = true;
              writableStoreOverlay = "/nix/.rw-store";
              hypervisor = "cloud-hypervisor";
            };
          }
          (
            # configuration.nix
            { pkgs, lib, ... }: {
              networking.hostName = name;
              system.stateVersion = lib.trivial.release;
              services.getty.autologinUser = "root";
              nix = {
                package = pkgs.nixVersions.latest;
                extraOptions = ''
                  experimental-features = nix-command flakes
                '';
              };
            }
          )
        ];
        # TODO: Add networking via bridge
        # https://astro.github.io/microvm.nix/simple-network.html
      };
    };
  };
}
