{
  inputs = {
    agentspace.url = "github:shazow/agentspace";
    microvm.url = "github:astro/microvm.nix";
  };

  outputs =
    {
      self,
      agentspace,
      ...
    }:
    let
      system = "x86_64-linux";
    in rec
    {
      nixosConfigurations.agentspace = agentspace.lib.mkSandbox {
        connectWith = "ssh";
        protocol = "virtiofs";
        sshAuthorizedKeys = import ./authorizedKeys.nix;
      };

      apps.${system}.default = {
        type = "app";
        program = agentspace.lib.mkLaunch nixosConfigurations.agentspace;
      };
    };
}

