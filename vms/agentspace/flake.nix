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
        persistence.basedir = statedir;

        # Powered by https://github.com/shazow/nixfiles/blob/main/modules/virtiofsd-nix-store.nix
        nixStoreShareSocket = "/var/run/virtiofs-nix-store.sock";

        writeFiles = {
          "/home/agent/.codex/auth.json" = {
            path = "/home/shazow/.config/codex/auth.json";
            chown = "agent:users";
            mode = "0600";
          };
          "/home/agent/.takopi/takopi.toml" = {
            path = "/home/shazow/.config/takopi/takopi.toml";
            chown = "agent:users";
            mode = "0600";
          };
        };

        # Yolo in the comfort of our VM
        ssh.command = ''tmux new-session -c ~/workspace -A -s codex "npx -y @openai/codex --yolo"'';
        ssh.authorizedKeys = import ./authorizedKeys.nix; # Could also do this with writeFiles

        # Get a notification when we suspend/resume/balloon/etc.
        notifications.command = ''notify-send "virtie: $VIRTIE_NOTIFY_STATE - $VIRTIE_NOTIFY_MESSAGE"'';

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
              pkgs.tmux

              (pkgs.writeShellApplication {
                name = "takopi";
                runtimeInputs = [
                  pkgs.python314
                  pkgs.uv
                ];
                text = ''
                  exec uv tool run --python ${pkgs.python314}/bin/python3 --from takopi@latest takopi "$@"
                '';
              })
            ];

            home.file.".config/agents/AGENTS.md".source = ./AGENTS.md;
            home.file.".codex/AGENTS.md".source = ./AGENTS.md;

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

