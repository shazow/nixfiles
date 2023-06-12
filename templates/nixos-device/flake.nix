{
  inputs = {
    nixfiles.url = "../../";
  };

  outputs = { nixfiles, ... }: let
    # FIXME: Replace this
    # $ mkpasswd hunter2
    hashedPassword = "$y$j9T$cKCdiliVyUYFTz6b6YC2K.$kLjtBxrCuzuxS//eMSLsHtXCkgkWimKq00cRdLzNBBB";
  in {
    nixosConfigurations = nixfiles.mkSystemConfigurations {
      inherit (nixfiles) devices;
      inherit hashedPassword;
    };
  };
}
