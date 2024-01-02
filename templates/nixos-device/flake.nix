{
  inputs = {
    # FIXME: Replace this with an absolute path
    nixfiles.url = "path:../../";
  };

  outputs = { nixfiles, ... }: {
    nixosConfigurations = nixfiles.mkSystemConfigurations {
      # FIXME: Replace this
      # $ mkpasswd hunter2
      initialHashedPassword = "$y$j9T$cKCdiliVyUYFTz6b6YC2K.$kLjtBxrCuzuxS//eMSLsHtXCkgkWimKq00cRdLzNBBB";
    };
  };
}

