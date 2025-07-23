{
  inputs.microvm = {
    url = "github:astro/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, microvm }: let
    system = "x86_64-linux";
  in {
    packages.${system} = {
      default = self.packages.${system}.browser-kiosk;
      browser-kiosk = self.nixosConfigurations.browser-kiosk.config.microvm.declaredRunner;
    };

    nixosConfigurations = {
      browser-kiosk = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          microvm.nixosModules.microvm
          {
            microvm = {
              graphics.enable = true;
              mem = 4096; # browser is thirsty and qemu hangs on 2048 for reasons
              shares = [
                {
                  # use proto = "virtiofs" for MicroVMs that are started by systemd
                  proto = "9p";
                  tag = "ro-store";
                  # a host's /nix/store will be picked up so that no
                  # squashfs/erofs will be built for it.
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                }
              ];

              hypervisor = "qemu";
              qemu.extraArgs = [
                # Handle fractal scaling on Wayland
                "-display" "sdl,gl=on"
              ];
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
            # configuration.nix
            { pkgs, lib, ... }: {
              networking.hostName = "browser-kiosk";
              system.stateVersion = lib.trivial.release;
              nixpkgs.config.allowUnfree = true;
              hardware.graphics.enable = true;
              users.users.guest.password = "";

              services.cage = {
                enable = true;
                program = "${pkgs.chromium}/bin/chromium";
                user = "guest";
              };
            }
          )
        ];
      };
    };
  };
}
