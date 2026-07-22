{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    agentspace.url = "github:shazow/agentspace";
    agentspace.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    #llm-agents.inputs.nixpkgs.follows = "nixpkgs";

    skills.url = "path:skills";
    skills.inputs.nixpkgs.follows = "nixpkgs";

    urllib3-shell.url = "path:../../shells/urllib3";
  };

  outputs =
    {
      agentspace,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      mkSandbox =
        {
          name ? "agentspace",
          spaces ? { },
          extraPackages ? [ ],
          extraModules ? [ ],
        }:
        (agentspace.lib.mkSandbox {
          hostName = "${name}-sandbox";

          # I like to put all the images and workspace data in one place, so it's easier to track
          persistence.baseDir = "/home/shazow/vms/${name}"; # Default: $PWD/.agentspace

          # Powered by https://github.com/shazow/nixfiles/blob/main/modules/virtiofsd-nix-store.nix
          nixStoreShareSocket = "/var/run/virtiofs-nix-store.sock";

          # Yolo in the comfort of our VM
          #ssh.command = ''tmux new-session -c $WORKSPACE -A -s codex "npx -y @openai/codex --yolo -C $WORKSPACE/*"'';
          # ^- No longer using tmux here because it borks codex BEL alerts
          ssh.authorizedKeys = import ./authorizedKeys.nix; # Could also do this with writeFiles

          # Additional files we inject at runtime over guest-agent socket
          writeFiles = import ./writeFiles.nix;

          # Get a notification when we suspend/resume/balloon/etc.
          notifications.command = ''notify-send "virtie: $VIRTIE_NOTIFY_STATE - $VIRTIE_NOTIFY_MESSAGE"'';

          #machine.vcpu = 16; # Default: Use all cores
          machine.memory = 12 * 1024;

          workspace = {
            enable = true;

            # Pass in which spaces we want to mount into $WORKSPACE, otherwise mount PWD
            inherit spaces;
            addCurrentDir = spaces == { };
          };

          extraModules = [
            (
              { pkgs, ... }:
              {
                nix.settings = {
                  extra-substituters = [
                    "https://cache.numtide.com" # For https://github.com/numtide/llm-agents.nix
                    "https://nix-community.cachix.org" # For https://github.com/modem-dev/hunk/
                  ];
                  extra-trusted-public-keys = [
                    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
                    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                  ];
                  extra-sandbox-paths = [
                    "/dev/vhost-vsock=/dev/vhost-vsock"
                  ];
                };

                nix.registry.nixpkgs.flake = inputs.nixpkgs;
                nix.registry.llm-agents.flake = inputs.llm-agents;

                programs.nh.enable = true;

                environment.systemPackages = [
                  # Languages
                  pkgs.nodejs
                  pkgs.bun
                  pkgs.go
                  pkgs.gcc # CGO
                  pkgs.pkg-config # CGO
                  (pkgs.python3.withPackages (python-pkgs: [
                    python-pkgs.uv
                  ]))

                  # Tools
                  pkgs.bubblewrap
                  pkgs.gnumake
                  pkgs.just
                  pkgs.tmux
                  pkgs.ripgrep
                  pkgs.jq

                  # Harness
                  # Can use the llm-agents overlay if you have the trusted substituter in host.
                  #pkgs.llm-agents.codex
                  pkgs.codex

                  # MCP
                  pkgs.mcp-nixos
                ]
                ++ extraPackages;
              }
            )
          ];

          homeModules = [
            # Inject the skills we care about from ./skills sub-flake
            #inputs.skills.homeModules.default

            (
              { pkgs, ... }:
              {
                home.packages = [
                  # Userland packages, if we want any...
                ];

                home.file.".config/agents/AGENTS.md".source = ./AGENTS.md;
                home.file.".codex/AGENTS.md".source = ./AGENTS.md;

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
        });
      defaultSandbox = mkSandbox { };
      packagesFromDevShell =
        devShell:
        let
          # Literally concatenate all possible package lists from the derivation
          combinedList =
            (devShell.packages or [ ])
            ++ (devShell.nativeBuildInputs or [ ])
            ++ (devShell.buildInputs or [ ])
            ++ (devShell.propagatedBuildInputs or [ ])
            ++ (devShell.propagatedNativeBuildInputs or [ ]);
        in
        # Filter to guarantee we only return actual package derivations
        builtins.filter (pkg: builtins.isAttrs pkg && pkg ? type && pkg.type == "derivation") combinedList;
    in
    {
      nixosConfigurations.agentspace = defaultSandbox;

      apps.${system} = {
        default = {
          type = "app";
          program = agentspace.lib.mkLaunch defaultSandbox;
        };
        connect = {
          type = "app";
          program = agentspace.lib.mkConnect defaultSandbox;
        };
        agentspace = {
          type = "app";
          program = agentspace.lib.mkLaunch (mkSandbox {
            spaces = {
              "agentspace" = "/home/shazow/projects/agentspace";
              "virtle" = "/home/shazow/projects/virtle";
            };
          });
        };
        urllib3 = {
          type = "app";
          program = agentspace.lib.mkLaunch (mkSandbox {
            name = "urllib3";
            spaces = {
              "urllib3" = "/home/shazow/projects/urllib3";
            };
            extraPackages = packagesFromDevShell inputs.urllib3-shell.devShells.${system}.default;
          });
        };
      };
    };
}
