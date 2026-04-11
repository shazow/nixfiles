{
  inputs = {
    agentspace.url = "github:shazow/agentspace";
  };

  outputs =
    {
      agentspace,
      ...
    }:
    let
      system = "x86_64-linux";
      statedir = "/home/shazow/vms/agentspace";
      sandbox = agentspace.lib.mkSandbox {
        connectWith = "ssh";
        protocol = "virtiofs";
        sshAuthorizedKeys = import ./authorizedKeys.nix;
        persistence.homeImage = "${statedir}/home.img";
        persistence.storeOverlay = "${statedir}/nix-store-overlay.img";
      };
    in
    {
      nixosConfigurations.agentspace = sandbox;

      apps.${system} = {
        default = {
          type = "app";
          program = agentspace.lib.mkLaunch sandbox;
        };
        connect = {
          type = "app";
          program = agentspace.lib.mkConnect sandbox;
        };
      };
    };
}

