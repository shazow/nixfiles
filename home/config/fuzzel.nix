# Fuzzel launcher configuration
# Replaces Rofi in Desktop 2025 Edition
{
  pkgs,
  lib,
  ...
}:
{
  programs.fuzzel = {
    enable = true;
    
    settings = {
      main = {
        # Terminal to launch programs that require it
        terminal = "wezterm";
        
        # Launcher behavior
        launch-prefix = "";
        
        # Number of results to display
        lines = 15;
        
        # Font configuration (matching other components)
        font = "DejaVu Sans Mono:size=12";
        
        # Prompt
        prompt = "$ ";
        
        # Icon theme
        icon-theme = "Adwaita";
        icons = true;
        
        # Fuzzy matching
        fuzzy = true;
        
        # Show actions
        show-actions = true;
        
        # Horizontal margin as percentage of screen width
        horizontal-pad = 40;
        
        # Vertical margin as percentage of screen height  
        vertical-pad = 8;
        
        # Inner padding
        inner-pad = 8;
        
        # Image size for icons
        image-size-ratio = 0.5;
        
        # Line height
        line-height = 25;
        
        # Letter spacing
        letter-spacing = 0;
        
        # Layer
        layer = "overlay";
        
        # Exit immediately if no results
        exit-on-keyboard-focus-loss = true;
      };
      
      # Colors matching the dark theme used elsewhere
      colors = {
        background = "222222dd";      # Dark background with some transparency
        text = "ddddddff";           # Light text
        match = "ffffffff";          # White for matches
        selection = "333333ff";      # Darker selection background
        selection-text = "ffffffff"; # White selection text
        selection-match = "f1c40fff"; # Yellow for selection matches
        border = "666666ff";         # Gray border
      };
      
      # Border configuration
      border = {
        width = 1;
        radius = 4;
      };
      
      # dmenu mode (for compatibility with rofi -dmenu usage)
      dmenu = {
        # Exit immediately when a selection is made
        exit-immediately-if-empty = false;
        
        # Print index instead of text
        print-index = false;
        
        # Case sensitivity
        case-sensitive = false;
      };
    };
  };
  
  # Helper scripts to replace rofi functionality
  home.packages = with pkgs; [
    # Clipboard manager integration
    (pkgs.writeShellScriptBin "fuzzel-clipboard" ''
      cliphist list | fuzzel --dmenu --prompt="clipboard: " | cliphist decode | wl-copy
    '')
    
    # Window switcher (basic implementation)
    (pkgs.writeShellScriptBin "fuzzel-windows" ''
      # This is a simplified version - full window switching would need niri integration
      # For now, just show a placeholder
      echo "Window switching via fuzzel not yet implemented" | fuzzel --dmenu --prompt="windows: "
    '')
    
    # Emoji picker
    (pkgs.writeShellScriptBin "fuzzel-emoji" ''
      # Use fuzzel with a simple emoji list
      # This replaces rofi -show emoji
      ${pkgs.gnome.gucharmap}/bin/gucharmap
    '')
    
    # Bookmark launcher (if bookmark script exists)
    (pkgs.writeShellScriptBin "fuzzel-bookmark" ''
      # Replaces the rofi bookmark functionality
      wl-paste | fuzzel --dmenu --prompt="bookmark: " | xargs -r bookmark | xargs -r -I '{}' xdg-open "obsidian://open/?path={}"
    '')
  ];
}
