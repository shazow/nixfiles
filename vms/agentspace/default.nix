{ inputs, system }:
let
  agentspace = inputs.agentspace;

  mkSandbox =
    {
      name ? "agentspace",
      spaces ? { },
      extraPackages ? [ ],
      extraModules ? [ ],
      forwardPorts ? [ ],
    }:
    agentspace.lib.mkSandbox {
      hostName = "${name}-sandbox";

      # Keep images and workspace data in one place so they are easy to track.
      persistence.baseDir = "/home/shazow/vms/${name}";
      persistence.storeOverlaySize = 1024 * 16;

      # Powered by modules/virtiofsd-nix-store.nix in this repository.
      nixStoreShareSocket = "/var/run/virtiofs-nix-store.sock";

      ssh.authorizedKeys = import ./authorizedKeys.nix;
      writeFiles = import ./writeFiles.nix;

      notifications.command = ''notify-send "virtie: $VIRTIE_NOTIFY_STATE - $VIRTIE_NOTIFY_MESSAGE"'';

      machine.memory = 12 * 1024;

      inherit forwardPorts;

      workspace = {
        enable = true;
        inherit spaces;
        addCurrentDir = spaces == { };
      };

      extraModules = [
        (
          { pkgs, ... }:
          {
            # Guest side of `forwardPorts`: the NixOS firewall is enabled by
            # default, so the forwarded ports need to be opened too.
            networking.firewall.allowedTCPPorts = map (forward: forward.guest.port) (
              builtins.filter (forward: (forward.proto or "tcp") == "tcp") forwardPorts
            );
            networking.firewall.allowedUDPPorts = map (forward: forward.guest.port) (
              builtins.filter (forward: (forward.proto or "tcp") == "udp") forwardPorts
            );

            nix.settings = {
              extra-substituters = [
                "https://cache.numtide.com"
                "https://nix-community.cachix.org"
              ];
              extra-trusted-public-keys = [
                "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              ];
              extra-sandbox-paths = [
                "/dev/vhost-vsock=/dev/vhost-vsock"
              ];
            };

            nix.registry.nixpkgs.flake = inputs.nixpkgs-unstable;
            nix.registry.llm-agents.flake = inputs.llm-agents;

            programs.nh.enable = true;

            environment.systemPackages = [
              # Languages
              pkgs.nodejs
              pkgs.bun
              pkgs.go
              pkgs.gcc
              pkgs.pkg-config
              (pkgs.python3.withPackages (python-pkgs: [ python-pkgs.uv ]))
              pkgs.devenv

              # Tools
              pkgs.bubblewrap
              pkgs.devenv
              pkgs.gnumake
              pkgs.just
              pkgs.tmux
              pkgs.ripgrep
              pkgs.jq

              # Harnesses
              pkgs.codex
              pkgs.claude-code

              # MCP
              pkgs.mcp-nixos
            ]
            ++ extraPackages;
          }
        )
      ]
      ++ extraModules;

      homeModules = [
        # Skills are pinned in ./skills.nix, but remain disabled by default.
        # (import ./skills.nix)

        (
          { ... }:
          {
            home.file.".config/agents/AGENTS.md".source = ./AGENTS.md;
            home.file.".codex/AGENTS.md".source = ./AGENTS.md;
            home.file.".claude/CLAUDE.md".source = ./AGENTS.md;

            programs =
              let
                name = "Andrey Petrov";
                email = "andrey.petrov@shazow.net";
              in
              {
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
          }
        )
      ];
    };

  packagesFromDevShell =
    devShell:
    let
      combinedList =
        (devShell.packages or [ ])
        ++ (devShell.nativeBuildInputs or [ ])
        ++ (devShell.buildInputs or [ ])
        ++ (devShell.propagatedBuildInputs or [ ])
        ++ (devShell.propagatedNativeBuildInputs or [ ]);
    in
    builtins.filter (pkg: builtins.isAttrs pkg && pkg ? type && pkg.type == "derivation") combinedList;

  sandboxes = {
    default = mkSandbox {
      forwardPorts = [
        {
          proto = "tcp";
          from = "host";
          host = {
            address = "127.0.0.1";
            port = 8080;
          };
          guest = {
            # Guest address on the user-mode (slirp) network.
            address = "10.0.2.15";
            port = 8080;
          };
        }
      ];
    };

    projects = mkSandbox {
      spaces = {
        nixfiles = "/home/shazow/projects/nixfiles";
        agentspace = "/home/shazow/projects/agentspace";
        virtle = "/home/shazow/projects/virtle";
      };
    };

    urllib3 = mkSandbox {
      name = "urllib3";
      spaces.urllib3 = "/home/shazow/projects/urllib3";
      extraPackages = packagesFromDevShell inputs.urllib3-shell.devShells.${system}.default;
    };
  };
in
{
  configurations = {
    agentspace = sandboxes.default;
    agentspace-projects = sandboxes.projects;
    agentspace-urllib3 = sandboxes.urllib3;
  };

  programs = builtins.mapAttrs (_: agentspace.lib.mkLaunch) sandboxes;
}
