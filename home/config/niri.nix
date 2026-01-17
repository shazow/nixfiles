{ pkgs, config,
  lockcmd,
  term ? "alacritty",
  launcher ? "fuzzel",
  bar ? "ironbar",
  portable ? false,
  ...
}:
let
  #mod = a: b: a - (b * (a / b)); # TODO: Use built-in function when available https://github.com/NixOS/nix/issues/12616
  #withAllWorkspaces = fn: lib.listToAttrs (lib.genList fn 10); # TODO: use this WIP helper
  windowcwd = pkgs.writeScript "windowcwd" ''
    pid=$(niri msg --json focused-window | jq .pid)
    ppid=$(pgrep --newest --parent $pid)
    readlink /proc/$ppid/cwd || echo $HOME
  '';
  fuzzel-emoji = pkgs.writeScript "fuzzel-emoji" ''
    cat ${pkgs.emoji-list}/emoji-list.txt | fuzzel --match-mode fuzzy --dmenu --tabs=2 | cut -f1 | wl-copy -n
  '';
in
with config.lib.niri.actions; {
  layout.gaps = 0;
  layout.background-color = "#000000";
  layout.preset-column-widths = [
    { proportion = 1. / 3.; }
    { proportion = 1. / 2.; }
    { proportion = 2. / 3.; }
    { proportion = 1.0; }
  ];
  layout.preset-window-heights = [
    { proportion = 1. / 3.; }
    { proportion = 1. / 2.; }
    { proportion = 2. / 3.; }
    { proportion = 1.0; }
  ];
  layout.focus-ring.enable = false;
  layout.tab-indicator = {
    enable = true;
    place-within-column = true;
    position = "top";
    hide-when-single-tab = true;
    length.total-proportion = 1.0;
    gaps-between-tabs = 5;
  };

  spawn-at-startup = [
    { argv = [ bar ]; }
  ];

  hotkey-overlay.skip-at-startup = true;

  # Outputs
  outputs."*" = {
    scale = 2;
    variable-refresh-rate = true;
  };
  outputs."BOE NE135A1M-NY1 Unknown" = {
    # Framework 13 Laptop
    scale = 1.75;
    variable-refresh-rate = true;
  };
  outputs."Dell Inc. AW3225QF HP20YZ3" = {
    scale = 2;
    variable-refresh-rate = true;
    mode = {
      width = 3840;
      height = 2160;
      refresh-rate = 120;
    };
  };

  # Input
  input.touchpad = {
    tap = true;
    dwt = true;
    natural-scroll = false;
    click-method = "clickfinger";
    scroll-method = "two-finger";
  };
  input.workspace-auto-back-and-forth = false;
  input.focus-follows-mouse.enable = true;

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
    "Mod+Alt+space".action = spawn "${fuzzel-emoji}";

    # Clipboard
    "Mod+Shift+v".action = spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";
    "Mod+Shift+d".action = spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist delete && notify-send 'Deleted clipboard item'";

    # Terminal
    "Mod+Return".action = spawn term;
    "Mod+Shift+Return".action = spawn "sh" "-c" "${term} --working-directory \"$(${windowcwd})\"";

    # Scratchpad
    "Mod+grave".action = spawn "scratchpad";

    # Window management
    "Mod+Shift+q".action = close-window;
    "Mod+Left".action = focus-column-left;
    "Mod+Right".action = focus-column-right;
    "Mod+Alt+Up".action = focus-window-up;
    "Mod+Alt+Down".action = focus-window-down;
    "Mod+Shift+BracketLeft".action = focus-window-up-or-column-left;
    "Mod+Shift+BracketRight".action = focus-window-down-or-column-right;
    "Mod+Up".action = focus-workspace-up;
    "Mod+Down".action = focus-workspace-down;
    "Mod+Shift+Left".action = move-column-left;
    "Mod+Shift+Right".action = move-column-right;
    "Mod+Shift+k".action = move-window-up;
    "Mod+Shift+j".action = move-window-down;
    "Mod+Shift+Up".action = move-window-to-workspace-up;
    "Mod+Shift+Down".action = move-window-to-workspace-down;
    "Mod+Comma".action = consume-or-expel-window-left;
    "Mod+Period".action = consume-or-expel-window-right;
    "Mod+Shift+Space".action = toggle-window-floating;
    "Mod+Tab".action = toggle-overview;
    "Alt+tab".action = focus-column-right-or-first;
    "Alt+Shift+tab".action = focus-window-previous;
    "Mod+f".action = fullscreen-window;
    "Mod+Shift+f".action = toggle-windowed-fullscreen;
    "Mod+Shift+w".action = toggle-column-tabbed-display;
    "Mod+w".action = spawn "niri-tabbed";
    "Mod+r".action = switch-preset-column-width;
    "Mod+Shift+r".action = switch-preset-window-height;

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

    "Mod+Shift+1".action.move-column-to-workspace = 1;
    "Mod+Shift+2".action.move-column-to-workspace = 2;
    "Mod+Shift+3".action.move-column-to-workspace = 3;
    "Mod+Shift+4".action.move-column-to-workspace = 4;
    "Mod+Shift+5".action.move-column-to-workspace = 5;
    "Mod+Shift+6".action.move-column-to-workspace = 6;
    "Mod+Shift+7".action.move-column-to-workspace = 7;
    "Mod+Shift+8".action.move-column-to-workspace = 8;
    "Mod+Shift+9".action.move-column-to-workspace = 9;
    "Mod+Shift+0".action.move-column-to-workspace = 10;

    # Lock & Suspend
    "Mod+l" = {
      action = spawn "sh" "-c" lockcmd;
      allow-inhibiting = false;
    };
    "Mod+Shift+minus" = {
      action = spawn "systemctl" "suspend";
      allow-when-locked = true;
    };

    # Screenshot
    "Mod+Print".action = spawn "sh" "-c" "slurp | grim -g - | satty --filename -";
    "Print".action.screenshot = {};
    "Shift+Print".action.screenshot-window = {};

    # Exit niri
    "Mod+Control+Delete".action = quit;
  };

  # Not sure I love this but helps hide the scratch window at the end...
  workspaces."scratch" = {};

  # Window rules
  # https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules
  window-rules = [
    {
      # All windows
      default-column-width.proportion = 2. / 3.;
      clip-to-geometry = true;
    }
    # {
    #   matches = [ { is-focused = true; } ];
    # }
    # {
    #   matches = [ { is-focused = false; } ];
    # }
    {
      matches = [ { app-id = "dropdown"; } ];
      open-on-workspace = "scratch";
      open-floating = true;

      default-floating-position = {
        x = 0;
        y = 0;
        relative-to = "top";
      };

      default-window-height.proportion = 0.4;
      default-column-width.proportion = 0.8;
    }
    {
      matches = [ { app-id = "^steam$"; title = "^notificationtoasts.*$"; } ];
      default-floating-position = {
        x = 25;
        y = 25;
        relative-to = "bottom-right";
      };

      open-focused = false;
    }
    {
      matches = [ { app-id = "^steam$"; } ];
      open-focused = false;
    }
    # {
    #   matches = [ { app-id = "org.wezfurlong.wezterm"; } ];
    # }
  ];

  debug = {
    # Workaround for https://github.com/YaLTeR/niri/issues/1948
    deactivate-unfocused-windows = [];
  };
}
