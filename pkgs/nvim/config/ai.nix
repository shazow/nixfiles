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
    copilot-lua.settings.copilot_model = "gpt-4o-copilot";  # Default is gpt-35-turbo, supports gpt-4o-copilot
    copilot-lua.package = pkgs.vimUtils.buildVimPlugin {
      name = "copilot-lua";
      src = pkgs.fetchFromGitHub {
        owner = "zbirenbaum";
        repo = "copilot.lua";
        rev = "826e46850ce0c33e39bcd78e474bc993d8e0fa84";
        hash = "sha256-K7GU4RNOLl5UBi2JiNV9N74EW8Dl3DTfwN6iL58ogZM=";
      };
    };
    copilot-cmp.enable = true;
    copilot-chat.enable = true;
    #copilot-chat.settings.model = "gpt4";
    avante.enable = true;
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
