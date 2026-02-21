# Full disk encryption using a btrfs filesystem with encrypted /boot and a
# separate swap device.
#
# Basically a wrapper around boot.* and filesystem.* but with different defaults.
{
  lib,
  config,
  ...
} @ toplevel:
with lib;
let
  cfg = config.nixfiles.bootlayout;
  btrfsOptions = [ "defaults" "noatime" "compress=zstd" ];
  mkIfElse = p: yes: no: mkMerge [
    (mkIf p yes)
    (mkIf (!p) no)
  ];
in {
  options.nixfiles.bootlayout = {
    enable = mkEnableOption ''
      Mount a full disk encryption setup using BTRFS, encrypted swap device, and a /boot/efi device.
    '';

    loader = mkOption {
      type = types.enum [ "systemd-boot" "grub" ];
      default = "systemd-boot";
    };

    luksDevices = toplevel.options.boot.initrd.luks.devices;

    efiDevice = mkOption {
      type = types.str;
      default = "/dev/disk/by-diskseq/1-part1";
    };

    rootDevice = mkOption {
      type = types.str;
      default = "/dev/mapper/cryptroot";
    };

    swapDevices = mkOption {
      type = types.listOf types.attrs;
      default = [ "/dev/mapper/cryptswap" ];
    };

    resumeDevice = mkOption {
      type = types.str;
      default = "";
    };

    volumes = mkOption {
      type = types.attrs;
      default = {
        # FIXME: My old systems use subvol=@rootnix but really we should call it @root if we migrate
        "/" = { options = btrfsOptions ++ [ "subvol=@rootnix" "nodiratime" "commit=100" ]; };
        "/home" = { options = btrfsOptions ++ [ "subvol=@home" ]; };
      };
    };

    extraVolumes = mkOption {
      description = "Additional btrfs volumes to mount on rootDevice";
      type = types.attrs;
      default = {};
      example = {
        "/nix" = { options = btrfsOptions ++ [ "subvol=@nix" "nodiratime" ]; };
      };
    };

    extraFileSystems = mkOption {
      type = toplevel.options.fileSystems.type;
      default = {};
      example = {
        "/mnt/diskstation" = {
          device = "diskstation:/volume1/share";
          fsType = "nfs";
          options = [ "auto" ];
        };
      };
    };
  };

  config = mkIf cfg.enable {

    # TODO: Add grub option?
    boot.loader = {
      grub.enable = false;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false; # Disable bypassing init
      };
    } // {
      # EFI
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    # LUKS
    boot.initrd.supportedFilesystems = [ "btrfs" "ntfs" ];
    boot.initrd.luks.devices = cfg.luksDevices;

    swapDevices = cfg.swapDevices;
    boot.resumeDevice = cfg.resumeDevice;

    fileSystems = {
      "/boot/efi" = {
        device = cfg.efiDevice;
        fsType = "vfat";
        options = [ "discard" ];
      };
    } // (
      builtins.mapAttrs (mount: volume: {
        device = cfg.rootDevice;
        fsType = "btrfs";
        options = volume.options;
      }) (cfg.volumes // cfg.extraVolumes)
    ) // cfg.extraFileSystems;

  };
}
