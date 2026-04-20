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

        extraModules = [
          {
            microvm.vcpu = 16;
            microvm.mem = 8 * 1024;
          }
        ];

        homeModules = [
          ({ pkgs, ... }: {
            home.packages = [
              pkgs.nodejs
              pkgs.go
              pkgs.gnumake
              pkgs.just
            ];

            home.file.".config/agents/AGENTS.md".source = ./AGENTS.md;

            programs = let
              name = "Andrey Petrov";
              email = "andrey.petrov@shazow.net";
            in {
              git = {
                enable = true;
                settings.user = {
                  inherit name email;
                };
              };
              jujutsu = {
                enable = true;
                settings.user = {
                  inherit name email;
                };
              };
            };
          })
        ];
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

