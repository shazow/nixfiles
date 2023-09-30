# Run with:
# nix eval --impure --expr 'import ./test.nix { pkgs = import <nixpkgs>; }'
{
  stdenv,
  lib,
  examplePackage,
  plugins ? import ./modules/plugins.nix,
  ...
}:
let
  mockBaseModule = {...}: with lib; {
    options = {
      extraPlugins = mkOption { type = with types; listOf (package); };
      extraConfigLua = mkOption { type = types.lines; default = ""; };
      maps = mkOption {};
    };
  };
  renderPlugins = cfg: (lib.evalModules({
    modules = [
      mockBaseModule
      plugins
    ];
    specialArgs = {
      config.pluginsWithConfig = cfg;
    };
  })).config;
in
  lib.runTests {
    testEmpty = {
      expr = renderPlugins {
        enable = true;
        plugins = [];
      };
      expected = {
        pluginsWithConfig = {
          enable = true;
          plugins = [];
        };
        extraPlugins = [];
        extraConfigLua = "";
      };
    };
    testKeymaps = {
      expr = renderPlugins{
        enable = true;
        plugins = [
          {
            plugin = examplePackage;
            keymaps = { "<foo>" = "bar"; };
            config = null;
            require = null;
          }
        ];
      };
      expected = {
        extraPlugins = [ examplePackage ];
        extraConfigLua = "";
        maps.normal = {
          "<foo>" = { silent = true; action = "bar"; lua = true; };
        };
      };
    };
    testExtraPlugins = {
      expr = renderPlugins{
        enable = true;
        plugins = [
          { plugin = examplePackage; config = "foo"; }
        ];
      };
      expected = {
        extraConfigLua = "foo";
        maps.normal = {};
        extraPlugins = [ examplePackage ];
      };
    };
  }
