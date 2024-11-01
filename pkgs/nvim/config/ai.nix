# TODO: Try also...
# - https://github.com/olimorris/codecompanion.nvim
# - https://github.com/frankroeder/parrot.nvim
# - https://github.com/yacineMTB/dingllm.nvim
{ pkgs, ... }:
{
  plugins = {
    # Copilot
    copilot-lua.enable = true;
    copilot-lua.suggestion.enabled = false; # Required for copilot-cmp
    copilot-lua.panel.enabled = false; # Required for copilot-cmp
    copilot-cmp.enable = true;
    copilot-chat.enable = true;
    avante.enable = true;
    avante.settings = {
      provider = "copilot";
    };
  };
}
