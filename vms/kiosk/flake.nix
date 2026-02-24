# Run any nixpkgs app as a QEMU graphical kiosk.
# Examples:
#   nix run .#foo
#   nix run .#chromium
{
  inputs.microvm = {
    url = "github:astro/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, microvm }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    pkgToKiosk = pkgName: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        microvm.nixosModules.microvm
        {
          microvm = {
            mem = 4096;
            graphics.enable = true;
            shares = [
              {
                proto = "9p";
                tag = "ro-store";
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
              }
            ];
            hypervisor = "qemu";
            interfaces = [
              {
                type = "user";
                id = "microvm1";
                mac = "02:02:00:00:00:01";
              }
            ];
          };
        }
        (
          { pkgs, lib, ... }: {
            networking.hostName = "${pkgName}-kiosk";
            system.stateVersion = lib.trivial.release;
            nixpkgs.config.allowUnfree = true;
            hardware.graphics.enable = true;
            users.users.guest = {
              isNormalUser = true;
              extraGroups = [ "video" "input" ];
            };

            services.cage = {
              enable = true;
              program = lib.getExe pkgs.${pkgName};
              user = "guest";
            };
          }
        )
      ];
    };

  in {
    legacyPackages.${system} = builtins.mapAttrs (name: pkg: 
      (pkgToKiosk name).config.microvm.declaredRunner
    ) pkgs;

    # Default kiosk: chromium
    packages.${system}.default = self.legacyPackages.${system}.chromium;
  };
}
