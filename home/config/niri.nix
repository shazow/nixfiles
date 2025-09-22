{ pkgs, config, lockcmd, term ? "alacritty", launcher ? "fuzzel", ... }:
with config.lib.niri.actions; {
  # General settings
  layout.gaps = 0;
  spawn-at-startup = [
  ];

  # Outputs
  outputs."*".scale = 2;

  # Input
  input.touchpad.tap = true;
  input.touchpad.dwt = true;
  input.focus-follows-mouse.enable = true;

  layout.background-color = "#000000";

  # Keybindings
  binds = {
    # Help
    "Mod+Shift+Slash".action = show-hotkey-overlay;

    # Special keys
    "XF86MonBrightnessUp".action = spawn "brightness" "up" "10";
    "XF86MonBrightnessDown".action = spawn "brightness" "down" "10";
    "Mod+XF86MonBrightnessUp".action = spawn "brightness" "up" "5";
    "Mod+XF86MonBrightnessDown".action = spawn "brightness" "down" "5";
    "XF86AudioRaiseVolume".action = spawn "volumectl" "up";
    "XF86AudioLowerVolume".action = spawn "volumectl" "down";
    "XF86AudioMute".action = spawn "volumectl" "mute";
    "XF86AudioMicMute".action = spawn "pamixer" "--default-source" "--toggle-mute";
    "XF86AudioPlay".action = spawn "playerctl" "play-pause";
    "XF86AudioPause".action = spawn "playerctl" "pause";
    "XF86AudioNext".action = spawn "playerctl" "next";
    "XF86AudioPrev".action = spawn "playerctl" "previous";

    # Display management
    # TODO: ... port sway config here

    # Application launcher
    "Mod+space".action = spawn launcher;

    # Clipboard
    "Mod+Shift+v".action = spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";
    "Mod+Shift+d".action = spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist delete && notify-send 'Deleted clipboard item'";

    # Terminal
    "Mod+Return".action = spawn term;

    # Window management
    "Mod+Shift+q".action = close-window;
    "Mod+Left".action = focus-column-left;
    "Mod+Right".action = focus-column-right;
    "Mod+Up".action = focus-window-up;
    "Mod+Down".action = focus-window-down;
    "Mod+Shift+Left".action = move-column-left;
    "Mod+Shift+Right".action = move-column-right;
    "Mod+Shift+k".action = move-window-up;
    "Mod+Shift+j".action = move-window-down;
    "Mod+Shift+Up".action = move-window-to-workspace-up;
    "Mod+Shift+Down".action = move-window-to-workspace-down;

    # Workspaces
    "Mod+1".action = focus-workspace 1;
    "Mod+2".action = focus-workspace 2;
    "Mod+3".action = focus-workspace 3;
    "Mod+4".action = focus-workspace 4;
    "Mod+5".action = focus-workspace 5;
    "Mod+6".action = focus-workspace 6;
    "Mod+7".action = focus-workspace 7;
    "Mod+8".action = focus-workspace 8;
    "Mod+9".action = focus-workspace 9;
    "Mod+0".action = focus-workspace 10;

    # Lock screen
    "Mod+l".action = spawn lockcmd;

    # Screenshot
    "Print".action = spawn "flameshot" "gui";
    "Shift+Print".action = spawn "flameshot" "full";

    # Exit niri
    "Mod+Control+Delete".action = quit;
  };

  # Window rules
  # https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules
  window-rules = [
    {
      # All windows
      default-column-width.proportion = 0.5;
    }
    # {
    #   matches = [ { is-focused = true; } ];
    # }
    # {
    #   matches = [ { is-focused = false; } ];
    # }
    {
      matches = [ { app-id = "dropdown"; } ];
      open-floating = true;
    }
    # {
    #   matches = [ { app-id = "org.wezfurlong.wezterm"; } ];
    # }
  ];
}
