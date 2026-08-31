{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    agentspace.url = "github:shazow/agentspace";
    agentspace.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";

    urllib3-shell.url = "path:../../shells/urllib3";
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
      agentspace = import ./. { inherit inputs system; };
      mkApp = program: {
        type = "app";
        inherit program;
      };
    in
    {
      nixosConfigurations.agentspace = agentspace.configurations.agentspace;

      apps.${system} = {
        default = mkApp agentspace.programs.default;
        agentspace = mkApp agentspace.programs.projects;
        urllib3 = mkApp agentspace.programs.urllib3;
      };
    };
}
