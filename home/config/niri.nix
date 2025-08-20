# Niri scrollable-tiling Wayland compositor configuration
# Migration from Sway to Niri
{
  pkgs,
  lib,
  config,
  
  lockcmd ? "${pkgs.swaylock}/bin/swaylock -fF",
  ...
}:
let
  mod = "Mod4";
  term = "alacritty";

  # Niri port of xcwd using niri msg to get focused window info
  windowcwd = pkgs.writeScript "windowcwd" ''
    #!/usr/bin/env bash
    # Get the focused window's PID using niri msg
    pid=$(niri msg focused-window | ${pkgs.jq}/bin/jq -r '.pid // empty')
    
    if [ -n "$pid" ] && [ "$pid" != "null" ]; then
      # Try to find the shell process (common parent patterns)
      for candidate_pid in $(pgrep -P "$pid" 2>/dev/null) "$pid"; do
        if [ -d "/proc/$candidate_pid" ]; then
          cwd=$(readlink "/proc/$candidate_pid/cwd" 2>/dev/null)
          if [ -n "$cwd" ] && [ -d "$cwd" ]; then
            echo "$cwd"
            exit 0
          fi
        fi
      done
    fi
    
    # Fallback to HOME if we can't determine the working directory
    echo "$HOME"
  '';

  # Dark mode script
  darkmode = pkgs.writeScript "darkmode" ''
    export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  '';
  # Push-to-talk script (same as sway)
  push-to-talk = pkgs.writeScript "push-to-talk" ''
    case $1 in
        on)
            pamixer --default-source -u
            pw-cat -p "${../../assets/sounds/ptt-activate.mp3}"
        ;;
        off)
            pamixer --default-source -m
            pw-cat -p "${../../assets/sounds/ptt-deactivate.mp3}"
        ;;
    esac
  '';

  # Niri configuration as KDL (corrected syntax)
  niriConfig = ''
    // Niri configuration file
    // Migrated from Sway configuration
    
    // Input configuration
    input {
        touchpad {
            tap
            dwt  // Disable while typing
        }
    }
    
    // Output configuration
    output "*" {
        scale 1.5
    }
    
    // Layout configuration - niri's scrollable tiling
    layout {
        gaps 4
        
        // Focus ring
        focus-ring {
            width 2
            active-color "#ffffff"
            inactive-color "#505050"
        }
        
        // Border configuration
        border {
            width 1
            active-color "#ffffff"
            inactive-color "#505050"
        }
    }
    
    // Spawn startup commands
    spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "--color" "#000000"
    spawn-at-startup "${darkmode}"
    
    // Cursor configuration
    cursor {
        size 24
        theme "default"
    }
    
    // Key bindings
    binds {
        // Terminal
        "Mod+Return" { spawn "${term}"; }
        "Mod+Shift+Return" { spawn "${term}" "--working-directory" "$(${windowcwd})"; }
        
        // Kill focused window
        "Mod+Shift+Q" { close-window; }
        
        // Application launcher
        "Mod+Space" { spawn "rofi" "-show" "run" "-p" "$ "; }
        "Mod+Shift+Tab" { spawn "rofi" "-show" "window" "-p" "[window] "; }
        
        // Lock screen
        "Mod+L" { spawn "${lockcmd}"; }
        "Print+L" { spawn "${lockcmd}"; }
        "XF86Launch2" { spawn "${lockcmd}"; }
        "Mod+Minus" { spawn "${lockcmd}"; }
        "Mod+Shift+Minus" { spawn "systemctl" "suspend"; }
        
        // Screenshot
        "Mod+Print" { spawn "flameshot" "launcher"; }
        "Mod+Shift+Print" { spawn "flameshot" "full"; }
        "Alt+Shift+4" { spawn "flameshot" "gui"; }
        
        // Clipboard
        "Mod+Shift+V" { spawn "sh" "-c" "cliphist list | rofi -dmenu | cliphist decode | wl-copy"; }
        "Mod+Shift+D" { spawn "sh" "-c" "cliphist list | dmenu | cliphist delete && notify-send 'Deleted clipboard item'"; }
        
        // Emoji
        "Mod+Alt+Space" { spawn "rofi" "-show" "emoji" "-modi" "emoji"; }
        
        // Bookmarks and notes
        "Mod+B" { spawn "sh" "-c" "wl-paste | rofi -dmenu | xargs bookmark | xargs -I '{}' xdg-open obsidian://open/?path={}"; }
        "Mod+N" { spawn "note"; }
        
        // Push-to-talk (note: release events may need special handling)
        "KP_Multiply" { spawn "${push-to-talk}" "on"; }
        
        // Media keys
        "XF86AudioRaiseVolume" { spawn "volumectl" "up"; }
        "XF86AudioLowerVolume" { spawn "volumectl" "down"; }
        "XF86AudioMute" { spawn "volumectl" "mute"; }
        "XF86AudioMicMute" { spawn "pamixer" "--default-source" "--toggle-mute"; }
        "XF86AudioPlay" { spawn "playerctl" "play-pause"; }
        "XF86AudioPause" { spawn "playerctl" "pause"; }
        "XF86AudioNext" { spawn "playerctl" "next"; }
        "XF86AudioPrev" { spawn "playerctl" "previous"; }
        
        // Brightness
        "XF86MonBrightnessUp" { spawn "brightness" "up" "10"; }
        "XF86MonBrightnessDown" { spawn "brightness" "down" "10"; }
        "Mod+XF86MonBrightnessUp" { spawn "brightness" "up" "5"; }
        "Mod+XF86MonBrightnessDown" { spawn "brightness" "down" "5"; }
        
        // Display switching (Framework laptop quirk)
        "XF86Display" { spawn "rofi-screenlayout"; }
        "Mod+P" { spawn "rofi-screenlayout"; }
        "Shift+XF86Display" { spawn "rofi-screenlayout" "_default"; }
        "Shift+Mod+P" { spawn "rofi-screenlayout" "_default"; }
        
        // Window management - niri's scrollable tiling approach
        "Mod+Left" { focus-column-left; }
        "Mod+Right" { focus-column-right; }
        "Mod+Up" { focus-window-up; }
        "Mod+Down" { focus-window-down; }
        
        "Mod+H" { focus-column-left; }
        "Mod+L" { focus-column-right; }
        "Mod+J" { focus-window-down; }
        "Mod+K" { focus-window-up; }
        
        // Move windows
        "Mod+Shift+Left" { move-column-left; }
        "Mod+Shift+Right" { move-column-right; }
        "Mod+Shift+Up" { move-window-up; }
        "Mod+Shift+Down" { move-window-down; }
        
        "Mod+Shift+H" { move-column-left; }
        "Mod+Shift+L" { move-column-right; }
        "Mod+Shift+J" { move-window-down; }
        "Mod+Shift+K" { move-window-up; }
        
        // Workspaces
        "Mod+1" { focus-workspace 1; }
        "Mod+2" { focus-workspace 2; }
        "Mod+3" { focus-workspace 3; }
        "Mod+4" { focus-workspace 4; }
        "Mod+5" { focus-workspace 5; }
        "Mod+6" { focus-workspace 6; }
        "Mod+7" { focus-workspace 7; }
        "Mod+8" { focus-workspace 8; }
        "Mod+9" { focus-workspace 9; }
        "Mod+0" { focus-workspace 10; }
        
        // Move to workspaces
        "Mod+Shift+1" { move-window-to-workspace 1; }
        "Mod+Shift+2" { move-window-to-workspace 2; }
        "Mod+Shift+3" { move-window-to-workspace 3; }
        "Mod+Shift+4" { move-window-to-workspace 4; }
        "Mod+Shift+5" { move-window-to-workspace 5; }
        "Mod+Shift+6" { move-window-to-workspace 6; }
        "Mod+Shift+7" { move-window-to-workspace 7; }
        "Mod+Shift+8" { move-window-to-workspace 8; }
        "Mod+Shift+9" { move-window-to-workspace 9; }
        "Mod+Shift+0" { move-window-to-workspace 10; }
        
        // Move between workspaces
        "Mod+Alt+Right" { focus-workspace-down; }
        "Mod+Alt+Left" { focus-workspace-up; }
        
        // Resize columns (niri's equivalent to window resizing)
        "Mod+R" { switch-preset-column-width; }
        
        // Fullscreen
        "Mod+F" { fullscreen-window; }
        
        // Column width adjustment (niri's take on "floating")
        "Mod+Shift+Space" { switch-preset-column-width; }
        
        // Exit niri
        "Mod+Ctrl+Delete" { quit; }
    }
    
    // Window rules
    window-rule {
        match app-id="dropdown"
        // TODO: Niri equivalent of scratchpad functionality
        // May need to use specific column width or workspace
    }
    
    window-rule {
        match window-type="dialog"
        // TODO: Configure dialog behavior in niri
    }
  '';

in
{
  # Create niri config directory and file
  home.file.".config/niri/config.kdl".text = niriConfig;
  
  # Systemd service for niri (if not using display manager)
  # Uncomment if you want to start niri via systemd
  # systemd.user.services.niri = {
  #   Unit = {
  #     Description = "Niri scrollable tiling Wayland compositor";
  #     After = [ "graphical-session-pre.target" ];
  #     PartOf = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.niri}/bin/niri";
  #     Restart = "on-failure";
  #     RestartSec = 1;
  #     TimeoutStopSec = 10;
  #   };
  # };

  # Environment variables for Wayland
  home.sessionVariables = {
    # Wayland-specific environment variables
    WAYLAND_DISPLAY = "wayland-1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    
    # Scale for QT applications to match output scaling
    QT_SCALE_FACTOR = "1.5";
  };
  
  # Wayland-related packages that work well with niri
  # Note: niri is available in stable nixpkgs
  home.packages = with pkgs; [
    # Core Wayland tools (same as used in sway config)
    swaybg          # Background
    swaylock        # Screen locking
    wl-clipboard    # Clipboard utilities
    
    # Application launcher and menus
    rofi-wayland    # Application launcher
    
    # Screenshot tools  
    flameshot       # Screenshots
    
    # Audio control
    pamixer         # Audio mixer
    pipewire        # Audio system
    
    # Brightness control
    # brightness    # Custom script, needs to be available
    
    # Media control
    playerctl       # Media player control
    
    # Clipboard history
    cliphist        # Clipboard manager
    
    # Notifications
    libnotify       # notify-send
    
    # Status bar (if not using niri's built-in status)
    i3status-rust   # Same status bar as sway config
  ];
}
