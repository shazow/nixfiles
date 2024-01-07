# Wayland alternative to x11.nix
{ pkgs, config, lib, inputs, ... }:
let
  sessionVars = {
    # For my fancy bookmark script: home/bin/bookmark
    BOOKMARK_DIR = "${config.home.homeDirectory}/remote/bookmarks";

    # Sway/Wayland env
    # (Should this be in wayland.windowManager.sway.config.extraSessionCommands?)
    GDK_BACKEND = "wayland"; # GTK
    XDG_SESSION_TYPE = "wayland"; # Electron
    SDL_VIDEODRIVER = "wayland"; # SDL
    QT_QPA_PLATFORM = "wayland"; # QT
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
  };

  lockcmd = "${pkgs.swaylock}/bin/swaylock -fF";

  # sway port of xcwd
  # via: https://www.reddit.com/r/swaywm/comments/ayedi1/opening_terminals_at_the_same_directory/ei7i1dl/?context=1
  windowcwd = pkgs.writeScript "windowcwd" ''
    pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.type=="con") | select(.focused==true).pid')
    ppid=$(pgrep --newest --parent $pid)
    readlink /proc/$ppid/cwd || echo $HOME
  '';
in
{
  nixpkgs.overlays = [ inputs.nixpkgs-wayland.overlay ];

  home.pointerCursor = {
    name = "capitaine-cursors";
    package = pkgs.capitaine-cursors;
    size = 24;
  };

  home.sessionVariables = sessionVars;

  gtk = {
    enable = true;
    theme = {
      package = pkgs.theme-vertex;
      name = "Vertex-Dark";
    };
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
  };

  services.gammastep = {
    enable = true;
    #tray = true;
    provider = "geoclue2";
    temperature.day = 5700;
    temperature.night = 3500;
  };

  programs.rofi = {
    enable = true;
    font = "DejaVu Sans Mono 14";
    theme = "Monokai";
    package = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
    extraConfig = {
      combi-mode = "window,drun,calc";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  home.packages = with pkgs; [
    swaybg
    gnome3.adwaita-icon-theme
  ];

  # The home-assistant services below won't work unless we're also using
  # home-manager's sway module.

  services.mako.enable = true;
  services.cliphist.enable = true;
  services.network-manager-applet.enable = true;

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = lockcmd; }
      { event = "lock"; command = "lock"; }
    ];
    timeouts = [
      # Turn off screen (just before locking)
      {
        timeout = 170;
        command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
      }
      # Lock computer
      {
        timeout = 180;
        command = lockcmd;
      }
    ];
  };

  # Not working? Need to try the stable version
  #services.swayosd.enable = true;

  wayland.windowManager.sway.swaynag.enable = true;

  # Note: We can also use program.sway but home-manager integrates systemd
  # graphical target units properly so that swayidle and friends all load
  # correctly together. It also handles injecting the correct XDG_* variables.
  wayland.windowManager.sway = {
    enable = true;

    config =
      let
        mod = "Mod4";
        term = "alacritty";
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
          { command = "${pkgs.swaybg}/bin/swaybg --color #000000"; }
        ];
        keybindings = lib.mkOptionDefault {
          # Special keys
          "XF86MonBrightnessUp" = "exec light -A 10";
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
          "${mod}+b" = "exec xclip -o | rofi -dmenu | xargs bookmark | xargs -I '{}' xdg-open obsidian://open/?path={}";
          "${mod}+XF86Display" = "exec xrandr --auto"; # Reset screen
          "${mod}+slash" = "exec xdotool key XF86AudioPlay"; # FIXME: Port to wayland
          "${mod}+bracketright" = "exec xdotool key XF86AudioNext"; # FIXME: Port to wayland
          "${mod}+bracketleft" = "exec xdotool key XF86AudioPrev"; # FIXME: Port to wayland
          "${mod}+Shift+i" = "exec xrandr-invert-colors"; # FIXME: Port to wayland

          # Kill focused window
          "${mod}+Shift+q" = "kill";

          # Jump to urgent
          "${mod}+x" = "[urgent=latest] focus";

          # Rofi
          "${mod}+space" = "exec rofi -show run -p '$ '";
          "${mod}+Shift+Tab" = "exec rofi -show window -p '[window] '";
          "${mod}+Shift+v" = "exec clipmenu";

          # Lock
          "${mod}+l" = "exec ${lockcmd}";
          "Print+l" = "exec ${lockcmd}";
          "XF86Launch2" = "exec ${lockcmd}";
          "${mod}+minus" = "exec ${lockcmd}";
          "${mod}+Shift+minus" = "exec systemctl suspend";

          # Emoji
          "${mod}+Mod1+space" = "exec --no-startup-id rofi -show emoji -modi emoji";

          # Screenshot
          "--release ${mod}+Print" = "exec ss"; # FIXME: Port to wayland
          "--release ${mod}+Shift+Print" = "exec maim -s | xclip -selection clipboard -t \"image/png\""; # FIXME: Port to wayland
          "--release Alt+Shift+4" = "exec maim -s | xclip -selection clipboard -t \"image/png\""; # FIXME: Port to wayland

          # Scratchpath
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

          # TODO: Port to wayland
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
            statusCommand = "i3status-rs $HOME/.config/i3/status.toml"; # TODO: Refer within repo
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
            command = "move scratchpad, borderhpixel 2, resize set 80 ppt 50 ppt, move absolute position 300 0";
          }
        ];
      };
  };

}
