# TODO: Try also...
# - https://github.com/olimorris/codecompanion.nvim
# - https://github.com/frankroeder/parrot.nvim
# - https://github.com/yacineMTB/dingllm.nvim
{ pkgs, ... }:
{
  plugins = {
    # Copilot
    copilot-lua.enable = true;
    copilot-lua.settings.suggestion.enabled = false; # Required for copilot-cmp
    copilot-lua.settings.panel.enabled = false; # Required for copilot-cmp
    copilot-cmp.enable = true;
    copilot-chat.enable = true;
    avante.enable = false;
    avante.settings = {
      provider = "claude";
    };
  };

  extraPlugins = with pkgs; [
  # {
  #   plugin = vimUtils.buildVimPlugin {
  #     name = "olimorris/codecompanion.nvim";
  #     src = fetchFromGitHub {
  #       owner = "olimorris";
  #       repo = "codecompanion.nvim";
  #       rev = "873c4eb7e1d8002ac1248ce1ada0761be8185d07"; # 8.4.1
  #       hash = "sha256-HGtaKsgM9+cUinDYWKthk9tTMbSIBsK/T/B9krW+drg=";
  #     };
  #   };
  # }
  ];

  extraConfigLua = ''
    --require("codecompanion").setup()
  '';
}
