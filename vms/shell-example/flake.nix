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
              interfaces = [{
                type = "tap";
                id = "vm-shell-example";
                mac = "02:00:00:00:00:01";
              }];
            };
          }
          (
            # configuration.nix
            { pkgs, lib, ... }: {
              networking.hostName = name;
              networking.useNetworkd = true;
              systemd.network.enable = true;
              systemd.network.networks."20-lan" = {
                matchConfig.Type = "ether";
                networkConfig.DHCP = "yes";
              };
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
        # Host configuration needed for bridge networking:
        # Option 1 - Using systemd-networkd (automatically handles TAP interfaces):
        # networking.useNetworkd = true; systemd.network.enable = true;
        # systemd.network.netdevs."br0".netdevConfig = { Name = "br0"; Kind = "bridge"; };
        # systemd.network.networks."10-lan".matchConfig.Name = ["eno1" "vm-*"];  # vm-* auto-adds TAP
        # systemd.network.networks."10-lan".networkConfig.Bridge = "br0";
        # 
        # Option 2 - Using NetworkManager (requires manual TAP addition):
        # networking.bridges.br0.interfaces = [ "eno1" ];  # Creates br0 bridge
        # networking.interfaces.br0.useDHCP = true;
        # Manual: ip link set vm-shell-example master br0  # TAP created after VM starts
      };
    };
  };
}
