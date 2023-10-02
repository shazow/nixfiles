{config, lib, ...}:
with lib;
let
  mergeAttrsets = a: lib.foldl' (acc: s: acc // s) {} a;
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

          keymaps = mkOption {
            type = attrsOf (either str attrs);
            description = "Keymaps for plugin.";
            default = {};
            example = {
              "<leader>fg" = "require('telescope.builtin').live_grep";
            };
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

    ### Borrowed from https://github.com/nix-community/nixvim/blob/3fa81dd06341ad9958b2b51b9e71448f693917f9/plugins/telescope/default.nix
    maps.normal = mergeAttrsets (map (p: mapAttrs (
       key: action: let
         actionStr =
           if isString action
           then action
           else action.action;
         actionProps =
           if isString action
           then {}
           else filterAttrs (n: v: n != "action") action;
       in
       {
         silent = true;
         action = actionStr;
         lua = true;
       }
       // actionProps) p.keymaps
     ) (filter (p: p.keymaps != {}) cfg.plugins));
  };
}
