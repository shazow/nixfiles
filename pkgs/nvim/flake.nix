{
  description = "A nixvim configuration";

  inputs = {
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = {
    nixpkgs,
    nixvim,
    flake-utils,
    ...
  }: let
    config = import ./config;
  in
    flake-utils.lib.eachDefaultSystem (system: let
      nixvimLib = nixvim.lib.${system};
      pkgs = import nixpkgs { inherit system; }; # Use the nixpkgs from inputs
      nixvim' = nixvim.legacyPackages.${system};
      nvim = nixvim'.makeNixvimWithModule {
        inherit pkgs;
        extraSpecialArgs = {
          nixvimHelpers = nixvim.lib.helpers;
        };
        module = config;
      };
    in {
      checks = {
        # Run `nix flake check .` to verify that your config is not broken
        default = nixvimLib.check.mkTestDerivationFromNvim {
          inherit nvim;
          name = "A nixvim configuration";
        };
        tests = let
          results = import ./tests.nix {
            inherit (pkgs) lib stdenv;
            examplePackage = pkgs.vimPlugins.vim-nix;
          };
        in
          # Could avoid this boilerplate using https://github.com/antifuchs/nix-flake-tests
          if results == []
          then pkgs.runCommand "lib-tests-success" {} "touch $out"
          else pkgs.runCommand "lib-tests-failure" {
            s = pkgs.lib.concatStringsSep "\n" (
              builtins.map (result: ''
                ${result.name}:
                  expected: ${builtins.toJSON result.expected}
                  result:   ${builtins.toJSON result.result}
              '')
              results
            );
          } ''
            echo -e "Tests failed:\\n\\n$s" >&2
            exit 1
          '';
      };

      packages = nvim;
      defaultPackage = nvim;

    });
}


