# Desktop 2025 Edition - Modern Wayland desktop setup
# This module imports all the modernized components
{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./niri.nix      # Niri compositor (replaces Sway)
    ./waybar.nix    # Waybar status bar (replaces i3status-rust)
    ./wezterm.nix   # Wezterm terminal (replaces Alacritty)
    ./fuzzel.nix    # Fuzzel launcher (replaces Rofi)
    ./stylix.nix    # Theming support
  ];
  
  # Additional desktop environment packages
  home.packages = with pkgs; [
    # File manager
    nautilus
    
    # Image viewer
    eog
    
    # Document viewer
    evince
    
    # Archive manager
    file-roller
    
    # System monitor
    gnome-system-monitor
    
    # Network manager GUI
    networkmanagerapplet
    
    # Bluetooth manager
    blueman
    
    # Notification daemon
    dunst
  ];
  
  # Services
  services = {
    # Notification daemon
    dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          geometry = "300x5-30+20";
          indicate_hidden = true;
          shrink = false;
          transparency = 0;
          notification_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 1;
          frame_color = "#586e75";
          separator_color = "frame";
          sort = true;
          idle_threshold = 120;
          font = "DejaVu Sans Mono 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          show_age_threshold = 60;
          word_wrap = true;
          ellipsize = "middle";
          ignore_newline = false;
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = true;
        };
        
        urgency_low = {
          background = "#002b36";
          foreground = "#93a1a1";
          timeout = 10;
        };
        
        urgency_normal = {
          background = "#002b36";
          foreground = "#93a1a1";
          timeout = 10;
        };
        
        urgency_critical = {
          background = "#dc322f";
          foreground = "#fdf6e3";
          frame_color = "#dc322f";
          timeout = 0;
        };
      };
    };
    
    # Network Manager applet
    network-manager-applet.enable = true;
    
    # Blueman applet
    blueman-applet.enable = true;
  };
  
  # XDG configuration
  xdg = {
    enable = true;
    
    # Desktop entries for applications
    desktopEntries = {
      niri = {
        name = "Niri";
        comment = "Scrollable-tiling Wayland compositor";
        exec = "niri";
        type = "Application";
        categories = [ "System" ];
      };
    };
    
    # Default applications
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "org.gnome.TextEditor.desktop" ];
        "application/pdf" = [ "org.gnome.Evince.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/png" = [ "org.gnome.eog.desktop" ];
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };
  };
  
  # Session variables for the desktop environment
  home.sessionVariables = {
    # Ensure applications know we're using Niri
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    
    # Desktop 2025 Edition identifier
    DESKTOP_EDITION = "2025";
  };
}
