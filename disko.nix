{
  disk ? "/dev/disk/by-diskseq/1",
  swapSize ? "",
  passwordFile, # Make sure there is no trailing space inside, e.g: echo -n "hunter2" > /tmp/secret.key
  lib,
  ...
}:
with lib; {
  disko.devices = {
    disk = {
      vdb = {
        device = disk;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            luks = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [ "--allow-discards" ];
              passwordFile = passwordFile;
              end = mkIf (swapSize != "") "-${swapSize}";
              content = {
                type = "btrfs";
                mountpoint = "/";
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
            swap = mkIf (swapSize != "") {
              size = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };
}
