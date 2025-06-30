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
              hotplugMem = 2048; # Extra memory that can be added if there's memory pressure
              storeOnDisk = true;
              writableStoreOverlay = "/nix/.rw-store";
              hypervisor = "cloud-hypervisor";
              interfaces = [
                {
                  # macvtap is more efficient than a plain tap bridge (which inspects every packet at the kernel level)
                  type = "macvtap";
                  macvtap = {
                    mode = "vepa"; # "bridge" for ethernet, "vepa" for wifi, or "private" if we don't want VMs to talk to each other
                    link = "microvm1@wlan0";
                    ## Need to make a user-owned macvtap device first
                    ## https://astro.github.io/microvm.nix/interfaces.html?highlight=macvtap#type--macvtap
                    ## TODO: Make this declarative somehow?
                    # sudo ip l add link $LINK name $ID type macvtap mode bridge
                    # IFINDEX=$(cat /sys/class/net/$ID/ifindex)
                    # sudo chown $USER /dev/tap$IFINDEX
                  };
                  id = "microvm1";
                  mac = "02:00:00:00:00:01";
                }
              ];
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

              networking = {
                useDHCP = true;
              };

              systemd.network.enable = true;
              systemd.network.networks."20-lan" = {
                matchConfig.Type = "ether";
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
