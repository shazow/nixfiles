{
  microvm,
  nixpkgs,
  system,
}:
let
  name = "shell-example";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    microvm.nixosModules.microvm
    {
      microvm = {
        mem = 1024;
        # hotplugMem = 2048; # cloud-hypervisor: Extra memory that can be added if there is memory pressure
        storeOnDisk = true;
        writableStoreOverlay = "/nix/.rw-store";
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
        networking.hostName = name;
        system.stateVersion = lib.trivial.release;
        services.getty.autologinUser = "root";
        nix = {
          package = pkgs.nixVersions.latest;
          extraOptions = ''
            experimental-features = nix-command flakes
          '';
        };

        systemd.network.enable = true;
      }
    )
  ];
  # TODO: Add networking via bridge.
  # https://astro.github.io/microvm.nix/simple-network.html
}
