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

      modules = [
        {
          nixfiles.bootlayout = {
            enable = true;
            # ... see modules/bootlayout.nix for options
          };
        }
      ];
    };
  };
}

