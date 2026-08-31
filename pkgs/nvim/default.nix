{ nixvim, system }:
let
  nixvimModule = {
    inherit system;
    extraSpecialArgs = {
      nixvimHelpers = nixvim.lib.helpers;
    };
    module = import ./config;
  };
in
{
  package = nixvim.legacyPackages.${system}.makeNixvimWithModule nixvimModule;
  check = nixvim.lib.${system}.check.mkTestDerivationFromNixvimModule nixvimModule;
}
