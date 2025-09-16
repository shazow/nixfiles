{ pkgs, lib, ... }:
let
  mod = "Mod4";
  term = "wezterm";
  lockcmd = "${pkgs.swaylock}/bin/swaylock -fF";
  scripts = import ../common/scripts.nix { inherit pkgs; };
  push-to-talk = scripts."push-to-talk";
in
with lib.niri.actions; {
  # General settings
  input.mod-key = mod;
  layout.gaps = 8;
  spawn-at-startup = [
    { argv = [ "swaybg" "--color" "#000000" ]; }
    { argv = [ "waybar" ]; }
  ];

  # Outputs
  outputs."*".scale = 1.5;

  # Input
  input."type:touchpad".tap = true;
  input."type:touchpad".dwt = true;

  # Keybindings
  binds = {
    # Special keys
    "XF86MonBrightnessUp".action = spawn "brightness" "up" "10";
    "XF86MonBrightnessDown".action = spawn "brightness" "down" "10";
    "${mod}+XF86MonBrightnessUp".action = spawn "brightness" "up" "5";
    "${mod}+XF86MonBrightnessDown".action = spawn "brightness" "down" "5";
    "XF86AudioRaiseVolume".action = spawn "volumectl" "up";
    "XF86AudioLowerVolume".action = spawn "volumectl" "down";
    "XF86AudioMute".action = spawn "volumectl" "mute";
    "XF86AudioMicMute".action = spawn "pamixer" "--default-source" "--toggle-mute";
    "XF86AudioPlay".action = spawn "playerctl" "play-pause";
    "XF86AudioPause".action = spawn "playerctl" "pause";
    "XF86AudioNext".action = spawn "playerctl" "next";
    "XF86AudioPrev".action = spawn "playerctl" "previous";

    # Display management
    "XF86Display".action = spawn "fuzzel"; # Niri doesn't have a direct equivalent for rofi-screenlayout
    "Mod4+p".action = spawn "fuzzel";

    # Application launcher
    "${mod}+space".action = spawn "fuzzel";

    # Clipboard
    "${mod}+Shift+v".action = spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";
    "${mod}+Shift+d".action = spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist delete && notify-send 'Deleted clipboard item'";

    # Terminal
    "${mod}+Return".action = spawn term;

    # Window management
    "${mod}+Shift+q".action = close-window;
    "${mod}+Left".action = focus-column-left;
    "${mod}+Right".action = focus-column-right;
    "${mod}+k".action = focus-window-up;
    "${mod}+j".action = focus-window-down;
    "${mod}+Shift+h".action = move-column-left;
    "${mod}+Shift+l".action = move-column-right;
    "${mod}+Shift+k".action = move-window-up;
    "${mod}+Shift+j".action = move-window-down;

    # Workspaces
    "${mod}+1".action = focus-workspace 1;
    "${mod}+2".action = focus-workspace 2;
    "${mod}+3".action = focus-workspace 3;
    "${mod}+4".action = focus-workspace 4;
    "${mod}+5".action = focus-workspace 5;
    "${mod}+6".action = focus-workspace 6;
    "${mod}+7".action = focus-workspace 7;
    "${mod}+8".action = focus-workspace 8;
    "${mod}+9".action = focus-workspace 9;
    "${mod}+0".action = focus-workspace 10;

    # Lock screen
    "${mod}+l".action = spawn lockcmd;

    # Screenshot
    "Print".action = spawn "flameshot" "gui";
    "Shift+Print".action = spawn "flameshot" "full";

    # Push to talk
    "KP_Multiply" = {
      action = spawn "${push-to-talk}" "on";
      repeat = false;
    };
    "release-KP_Multiply".action = spawn "${push-to-talk}" "off";

    # Exit niri
    "${mod}+Shift+e".action = quit;
  };

  # Window rules
  window-rules = [
    {
      matches = [ { title = ".*"; } ]; # Apply to all windows
      border.enable = true;
      border.width = 2;
    }
    {
      matches = [ { is-focused = true; } ];
      border.active.color = "#FF0000";
    }
    {
      matches = [ { is-focused = false; } ];
      border.inactive.color = "#888888";
    }
    {
      matches = [ { app-id = "dropdown"; } ];
      open-floating = true;
    }
  ];
}
