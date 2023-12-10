# Run with:
# nix eval --impure --expr 'import ./testeval.nix { inherit (import <nixpkgs> {}) lib stdenv; }'
{ stdenv
, lib
, ...
}:
let
  mockBaseModule = { config, ... }: with lib; {
    options = {
      someNumbers = mkOption { type = with types; listOf (number); };
      someString = mkOption { type = types.lines; default = ""; };
    };

    config = {
    };
  };
in
lib.runTests {
  testFoo = {
    expr = let
      config = {
        someNumbers = [42];
      };
    in (lib.evalModules ({
      modules = [ mockBaseModule config ];
    })).config;
    expected = {
      someNumbers = [42];
      someString = "";
    };
  };
}
