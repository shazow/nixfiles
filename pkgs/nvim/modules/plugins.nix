{config, lib, ...}:
with lib;
let
  cfg = config.pluginsWithConfig;
in {
  options = {
    pluginsWithConfig = mkOption {
      type = with types; listOf (submodule {
        options = {
          config = mkOption {
            type = types.nullOr types.lines;
            description = "Lua configuration for plugin.";
            default = null;
          };

          plugin = mkOption {
            type = types.package;
            description = "vim plugin";
          };
        };
      });
    };
  };

  config.extraPlugins = map (p: p.plugin) cfg;
  config.extraConfigLua = concatStringsSep "\n\n" (map (p: p.config) cfg);
}
