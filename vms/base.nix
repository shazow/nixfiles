{ inputs, config, lib, pkgs, primaryUsername, ... }:

{
  system.stateVersion = "24.11";

  # Default user configuration
  users.users.${primaryUsername} = {
    isNormalUser = true;
    password = "password";
    extraGroups = [ "wheel" "video" "audio" ];
    uid = 1000;
  };

  security.sudo.wheelNeedsPassword = false;

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
  # MicroVM usually doesn't need explicit interface config if using user networking + slirp?
  # But if interface is defined, systemd-networkd might try to manage it.
  # Let's keep minimal.
}
