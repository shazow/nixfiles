{
  inputs = {
    # FIXME: Replace this with an absolute path
    nixfiles.url = "../../";
  };

  outputs = { nixfiles, ... }: let
    # FIXME: Replace this
    # $ mkpasswd hunter2
    initialHashedPassword = "$y$j9T$cKCdiliVyUYFTz6b6YC2K.$kLjtBxrCuzuxS//eMSLsHtXCkgkWimKq00cRdLzNBBB";

    # Example of additional disk layout configs can be overridden below:
    # disk = {
    #   efi = { device = "/dev/disk/by-id/..."; };
    #   luksDevices = {
    #     cryptmedia = { device = "/dev/disk/by-id/..."; };
    #   };
    #   extraFileSystems = {
    #     "/mnt/media" = { device = "/dev/mapper/cryptmedia"; fsType = "btrfs"; };
    #   };
    # };
  in {
    nixosConfigurations = nixfiles.mkSystemConfigurations {
      inherit (nixfiles) devices;
      inherit initialHashedPassword;
      # inherit disk;
    };
  };
}
