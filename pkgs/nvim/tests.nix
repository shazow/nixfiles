# Run with:
# nix eval --impure --expr 'import ./tests.nix { inherit (import <nixpkgs> {}) lib stdenv; }'
{ stdenv
, lib
, examplePackage ? derivation { name = "examplePackage"; builder = "true"; system = "testin"; }
, plugins ? import ./modules/plugins.nix
, ...
}:
let
  mockBaseModule = { ... }: with lib; {
    options = {
      extraPlugins = mkOption { type = types.listOf (types.package); };
      extraConfigLua = mkOption { type = types.lines; default = ""; };
      keymaps = mkOption { type = types.listOf types.attrs; default = []; };
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
      keymaps = [];
    };
  };
  testKeymaps = mkPluginTest {
    plugins = [
      {
        plugin = examplePackage;
        keymaps = [
          { key = "<foo>"; action = "bar"; }
        ];
      }
    ];
    wantConfig = {
      extraPlugins = [ examplePackage ];
      extraConfigLua = "";
      keymaps = [
        { key = "<foo>"; action = "bar"; }
      ];
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
      extraPlugins = [ examplePackage ];
      keymaps = [];
    };
  };
}
