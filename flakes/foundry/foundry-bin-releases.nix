{
  version = "0.0.0";

  sources = {
    # Map foundry's release naming scheme to nix's system keys
    "x86_64-linux" = {
      url = "https://github.com/gakonst/foundry/releases/download/nightly-ecfbcabfdcee603bb46c54b910d3656b560606c6/foundry_nightly_linux_amd64.tar.gz";
      sha256 = "sha256-xTNyjRuQiK+qi7PQg5gzFbFTMClS+JpyA2zRNTVaf9Y=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/gakonst/foundry/releases/download/nightly-ecfbcabfdcee603bb46c54b910d3656b560606c6/foundry_nightly_darwin_amd64.tar.gz";
      sha256 = ""; # TODO: ...
    };
    "aarch64-darwin" = {
      url = "https://github.com/gakonst/foundry/releases/download/nightly-ecfbcabfdcee603bb46c54b910d3656b560606c6/foundry_nightly_darwin_arm64.tar.gz";
      sha256 = ""; # TODO: ...
    };

    # TODO: "x86_64-cygwin" = "foundry_nightly_win32_amd64.zip";
  };
}
