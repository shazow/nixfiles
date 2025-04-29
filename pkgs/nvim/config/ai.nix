# TODO: Try also...
# - https://github.com/olimorris/codecompanion.nvim
# - https://github.com/frankroeder/parrot.nvim
# - https://github.com/yacineMTB/dingllm.nvim
{ pkgs, ... }:
{
  plugins = {
    # Copilot
    copilot-lua = {
      enable = true;
      settings.suggestion.enabled = false; # Required for copilot-cmp
      settings.panel.enabled = false; # Required for copilot-cmp
      settings.copilot_model = "gpt-4o-copilot";  # Default is gpt-35-turbo, supports gpt-4o-copilot
      # Load on insert or command
      lazyLoad.settings.event = "InsertEnter";
      lazyLoad.settings.cmd = [ "Copilot" "CopilotAuth" ];
    };
    copilot-cmp = {
      enable = true;
      # Load after copilot.lua and nvim-cmp
      lazyLoad.settings.after = [ "copilot.lua" "nvim-cmp" ];
    };
    copilot-chat = {
      enable = true;
      #copilot-chat.settings.model = "gpt4";
      lazyLoad.settings.cmd = "CopilotChat";
      # Consider adding keymaps if you have specific ones for CopilotChat actions
    };
    avante = {
      enable = true;
      lazyLoad.settings.cmd = "Avante";
      settings = {
        provider = "claude";
      };
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
