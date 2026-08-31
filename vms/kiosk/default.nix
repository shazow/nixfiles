{
  microvm,
  nixpkgs,
  system,
}:
let
  pkgs = nixpkgs.legacyPackages.${system};

  pkgToKiosk =
    pkgName:
    nixpkgs.lib.nixosSystem {
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
          { pkgs, lib, ... }:
          {
            networking.hostName = "${pkgName}-kiosk";
            system.stateVersion = lib.trivial.release;
            nixpkgs.config.allowUnfree = true;
            hardware.graphics.enable = true;
            users.users.guest = {
              isNormalUser = true;
              group = "guest";
              extraGroups = [
                "video"
                "input"
              ];
            };
            users.groups.guest = { };

            services.cage = {
              enable = true;
              program = lib.getExe pkgs.${pkgName};
              user = "guest";
            };
          }
        )
      ];
    };
in
builtins.mapAttrs (name: _: (pkgToKiosk name).config.microvm.declaredRunner) pkgs
