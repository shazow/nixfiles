{
  description = "Local VM configurations and runners";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    agentspace.url = "github:shazow/agentspace";
    agentspace.inputs.nixpkgs.follows = "nixpkgs-unstable";

    llm-agents.url = "github:numtide/llm-agents.nix";

    urllib3-shell.url = "path:../shells/urllib3";

  };

  outputs =
    inputs@{
      microvm,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      agentspace = import ./agentspace { inherit inputs system; };
      browserKiosk = import ./browser-kiosk { inherit microvm nixpkgs system; };
      shellExample = import ./shell-example { inherit microvm nixpkgs system; };

      mkRunnable =
        name: program:
        pkgs.writeShellScriptBin name ''
          exec ${program} "$@"
        '';

      agentspaceRunners = {
        default = mkRunnable "agentspace" agentspace.programs.default;
        projects = mkRunnable "agentspace-projects" agentspace.programs.projects;
        urllib3 = mkRunnable "agentspace-urllib3" agentspace.programs.urllib3;
      };
    in
    {
      nixosConfigurations = agentspace.configurations // {
        browser-kiosk = browserKiosk;
        shell-example = shellExample;
      };

      packages.${system} = {
        browser-kiosk = browserKiosk.config.microvm.declaredRunner;
        shell-example = shellExample.config.microvm.declaredRunner;
      };

      apps.${system}.agentspace = {
        type = "app";
        program = agentspace.programs.default;
      };

      legacyPackages.${system} = {
        agentspace = agentspaceRunners;
        kiosks = import ./kiosk { inherit microvm nixpkgs system; };
      };
    };
}
