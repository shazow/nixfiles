{config, lib, ...}:
with lib;
let
  cfg = config.morePlugins;
in {
  options.morePlugins = {
    enable = mkEnableOption "Enable plugins with even more helpers.";

    plugins = mkOption {
      default = [];
      type = with types; listOf (submodule {
        options = {
          plugin = mkOption {
            type = package;
            description = "Vim plugin.";
          };

          config = mkOption {
            type = nullOr lines;
            description = "Lua configuration for plugin. Overrides setup.";
            default = null;
          };

          require = mkOption {
            type = nullOr str;
            description = "Lua module to require('...').setup({}) by default.";
            default = null;
          };

          setup = mkOption {
            type = str;
            description = "Lua code to pass into setup({...}).";
            default = "{}";
          };

          # TODO: keymaps = nixvimHelpers.keymaps;
          keymaps = mkOption {
            type = listOf attrs;
            default = [];
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    extraPlugins = map (p: p.plugin) cfg.plugins;
    extraConfigLua = let
      morePluginsLua = concatStringsSep "\n\n" (
        map (p:
          if p.config != null
          then p.config
          else if p.require != null
          then "require('${p.require}').setup(${p.setup})"
          else ""
        ) cfg.plugins);
    in mkIf (morePluginsLua != "") ''
      -- {{{ morePlugins
      ${morePluginsLua}
      -- }}}
    '';

    keymaps = builtins.concatLists (map (p: p.keymaps) cfg.plugins);
  };
}
