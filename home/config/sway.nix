# wayland.windowManager.sway.config
{
  pkgs,
  lib,

  lockcmd ? "${pkgs.swaylock}/bin/swaylock -fF",
  ...
}:
let
  mod = "Mod4";
  term = "alacritty";

  # sway port of xcwd
  # via: https://www.reddit.com/r/swaywm/comments/ayedi1/opening_terminals_at_the_same_directory/ei7i1dl/?context=1
  windowcwd = pkgs.writeScript "windowcwd" ''
    pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.type=="con") | select(.focused==true).pid')
    ppid=$(pgrep --newest --parent $pid)
    readlink /proc/$ppid/cwd || echo $HOME
  '';

  # FIXME: This doesn't actually work, but sounds like a good idea in theory lol
  darkmode = pkgs.writeScript "darkmode" ''
    export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  '';
in
{
  modifier = mod;
  terminal = term;
  window.border = 1;
  window.hideEdgeBorders = "both";
  colors.background = "#000000";
  fonts = {
    names = [ "DejaVu Sans Mono" "FontAwesome" ];
    style = "Bold Semi-Condensed";
    size = 10.0;
  };
  startup = [
    { command = "${pkgs.swaybg}/bin/swaybg --color \"#000000\""; }
    { command = "${darkmode}"; }
  ];
  keybindings = lib.mkOptionDefault {
    # Special keys
    "XF86MonBrightnessUp" = "exec light -A 10"; # TODO: Port wrapper using `ddcutil setvcp 10 + 5` on desktop?
    "XF86MonBrightnessDown" = "exec light -U 10";
    "${mod}+XF86MonBrightnessUp" = "exec light -A 2";
    "${mod}+XF86MonBrightnessDown" = "exec light -U 2";
    "XF86AudioRaiseVolume" = "exec --no-startup-id volumectl up";
    "XF86AudioLowerVolume" = "exec --no-startup-id volumectl down";
    "XF86AudioMute" = "exec --no-startup-id volumectl mute";
    "XF86AudioMicMute" = "exec --no-startup-id pamixer --default-source --toggle-mute";
    "XF86AudioPlay" = "exec playerctl play-pause";
    "XF86AudioPause" = "exec playerctl pause";
    "XF86AudioNext" = "exec playerctl next";
    "XF86AudioPrev" = "exec playerctl previous";
    "XF86Display" = "exec rofi-screenlayout";
    "${mod}+b" = "exec wl-paste | rofi -dmenu | xargs bookmark | xargs -I '{}' xdg-open obsidian://open/?path={}";
    "${mod}+XF86Display" = "exec xrandr --auto"; # Reset screen

    # Kill focused window
    "${mod}+Shift+q" = "kill";

    # Jump to urgent
    "${mod}+x" = "[urgent=latest] focus";

    # Rofi
    "${mod}+space" = "exec rofi -show run -p '$ '";
    "${mod}+Shift+Tab" = "exec rofi -show window -p '[window] '";
    "${mod}+Shift+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
    "${mod}+Shift+d" = "exec cliphist list | dmenu | cliphist delete && notify-send \"Deleted clipboard item\"";

    # Lock
    "${mod}+l" = "exec ${lockcmd}";
    "Print+l" = "exec ${lockcmd}";
    "XF86Launch2" = "exec ${lockcmd}";
    "${mod}+minus" = "exec ${lockcmd}";
    "${mod}+Shift+minus" = "exec systemctl suspend";

    # Emoji
    "${mod}+Mod1+space" = "exec --no-startup-id rofi -show emoji -modi emoji | wl-paste";

    # Screenshot
    "--release ${mod}+Print" = "exec flameshot launcher";
    "--release ${mod}+Shift+Print" = "exec flameshot full";
    "--release Alt+Shift+4" = "exec flameshot gui";

    # Scratchpad
    "${mod}+Shift+grave" = "move scratchpad";
    #for_window [instance="dropdown"] move scratchpad, border pixel 2, resize set 80 ppt 50 ppt, move absolute position 300 0
    "${mod}+grave" = "exec --no-startup-id i3-scratchpad \"dropdown\"";

    # start a terminal
    "${mod}+Return" = "exec ${term}";
    "${mod}+Shift+Return" = "exec ${term} --working-directory \"$(${windowcwd})\"";

    # Workspaces
    "${mod}+Mod1+Right" = "workspace next";
    "${mod}+Mod1+Left" = "workspace prev";
    "${mod}+Control+Left" = "move workspace to output left";
    "${mod}+Control+Right" = "move workspace to output right";

    "${mod}+Control+Delete" = "exec swaynag -t warning -m 'Quit wayland?' -b 'Yes' 'swaymsg exit'";
  };
  bars = [
    {
      colors.background = "#222222";
      colors.separator = "#666666";
      colors.statusline = "#dddddd";
      fonts = {
        names = [ "DejaVu Sans Mono" "FontAwesome" ];
        size = 12.0;
      };
      # TODO: Port to native config
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3/status.toml}";
    }
  ];
  modes = {
    resize = {
      "Left" = "resize shrink width 10 px or 10 ppt";
      "Down" = "resize grow height 10 px or 10 ppt";
      "Up" = "resize shrink height 10 px or 10 ppt";
      "Right" = "resize grow width 10 px or 10 ppt";
      "${mod}+Left" = "resize shrink width 5 px or 5 ppt";
      "${mod}+Down" = "resize grow height 5 px or 5 ppt";
      "${mod}+Up" = "resize shrink height 5 px or 5 ppt";
      "${mod}+Right" = "resize grow width 5 px or 5 ppt";
      "Escape" = "mode default";
      "Return" = "mode default";
      "${mod}+r" = "mode default";

      # Picture-in-picture helpers
      "${mod}+s" = "sticky toggle, mode default";
      "${mod}+p" = "resize set 30 ppt 40 ppt, move absolute position 1800 0, mode default, sticky toggle";
      "${mod}+m" = "resize set 80 ppt 50 ppt, move absolute position 300 0, mode default";
    };
    nag = {
      "Escape" = "exec swaynagmode --exit";
      "Return" = "exec swaynagmode --confirm";
      "Left" = "exec swaynagmode --select next";
      "Right" = "exec swaynagmode --select prev";
    };
  };
  window.commands = [
    {
      criteria = { app_id = "dropdown"; };
      command = "move scratchpad";
    }
  ];
}
