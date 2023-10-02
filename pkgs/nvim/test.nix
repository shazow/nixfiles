# Run with:
# nix eval --impure --expr 'import ./test.nix { inherit (import <nixpkgs> {}) lib stdenv; }'
{ stdenv
, lib
, examplePackage ? derivation { name = "examplePackage"; builder = "true"; system = "testin"; }
, plugins ? import ./modules/plugins.nix
, ...
}:
let
  mockBaseModule = { ... }: with lib; {
    options = {
      extraPlugins = mkOption { type = with types; listOf (package); };
      extraConfigLua = mkOption { type = types.lines; default = ""; };
      maps = mkOption { };
    };
  };
  renderPlugins = config: (lib.evalModules ({
    modules = [
      mockBaseModule
      plugins
      config
    ];
  })).config;
  mkPluginTest = { plugins, wantConfig }:
    let
      config = {
        morePlugins = {
          enable = true;
          plugins = plugins;
        };
      };
    in
    {
      # Remove input config from our comparison results
      expr = removeAttrs (renderPlugins config) (builtins.attrNames config);
      expected = wantConfig;
    };
in
lib.runTests {
  testEmpty = mkPluginTest {
    plugins = [];
    wantConfig = {
      extraPlugins = [];
      extraConfigLua = "";
      maps.normal = {};
    };
  };
  testKeymaps = mkPluginTest {
    plugins = [
      {
        plugin = examplePackage;
        keymaps = { "<foo>" = "bar"; };
      }
    ];
    wantConfig = {
      extraPlugins = [ examplePackage ];
      extraConfigLua = "";
      maps.normal = {
        "<foo>" = { silent = true; action = "bar"; lua = true; };
      };
    };
  };
  testExtraPlugins = mkPluginTest {
    plugins = [
      { plugin = examplePackage; config = "foo"; }
    ];
    wantConfig = {
      extraConfigLua = ''
        -- {{{ morePlugins
        foo
        -- }}}
      '';
      maps.normal = { };
      extraPlugins = [ examplePackage ];
    };
  };
}
