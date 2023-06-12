{
  inputs = {
    nixfiles.url = "../../";
  };

  outputs = { nixfiles, ... }: {
    nixosConfigurations = nixfiles.mkSystemConfigurations {
      devices = nixfiles.devices;
      hashedPassword = "$y$j9T$cKCdiliVyUYFTz6b6YC2K.$kLjtBxrCuzuxS//eMSLsHtXCkgkWimKq00cRdLzNBBB"; # mkpasswd hunter2, replace this
    };
  };
}
