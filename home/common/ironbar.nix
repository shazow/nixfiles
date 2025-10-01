{ pkgs, pkgs-unstable, lib, ... }:
let
  pkg = pkgs-unstable.ironbar;
in
{

  home.packages = [
    pkg
  ];

  xdg.configFile = {
    "ironbar/config.corn" = {
      onChange = "${lib.getExe pkg} reload";
      text = # corn
      ''
        let {
          $workspaces = {
              type = "workspaces"
              all_monitors = false
              hidden = [ "scratch" ]
          }

          $focused = { type = "focused" }

          $notifications = {
              type = "notifications"
              show_count = true

              icons.closed_none = "󰍥"
              icons.closed_some = "󱥂"
              icons.closed_dnd = "󱅯"
              icons.open_none = "󰍡"
              icons.open_some = "󱥁"
              icons.open_dnd = "󱅮"
          }

          $sys_info = {
              type = "sys_info"

              interval.memory = 30
              interval.cpu = 1
              interval.temps = 5
              interval.disks = 300
              interval.networks = 3

              format = [
              " {cpu_percent}% | {cpu_frequency} GHz | {temp_c@CPUTIN}°C"
              " {memory_used} / {memory_total} GB ({memory_available} | {memory_percent2}%) | {swap_used} / {swap_total} GB ({swap_free} | {swap_percent}%)"
              "󰋊 {disk_used#T@/:.1} / {disk_total#T@/:.1} TB ({disk_percent@/}%) | {disk_read} / {disk_write} MB/s"
              "󰓢 {net_down@enp39s0} / {net_up@enp39s0} Mbps"
              "󰖡 {load_average1} | {load_average5} | {load_average15}"
              "󰥔 {uptime}"
              ]
          }

          $tray = { type = "tray" }

          $clock = { type = "clock" }

          $clipboard = { type = "clipboard" max_items = 3 truncate.mode = "end" truncate.length = 50 }

          $volume = {
              type = "volume"
              format = "{icon} {percentage}%"
              max_volume = 100
              icons.volume_high = "󰕾"
              icons.volume_medium = "󰖀"
              icons.volume_low = "󰕿"
              icons.muted = "󰝟"
          }

          $left = [
            $workspaces
          ]

          $right = [
            $sys_info
            $volume
            $clipboard
            $clock
            $notifications
          ]
      }
      in {
          anchor_to_edges = true
          position = "bottom"
          icon_theme = "Paper"

          start = $left
          end = $right
      }
      '';
    };

    "ironbar/style.css" = {
      text = # css
      ''
        @define-color color_bg #2d2d2d;
        @define-color color_bg_dark #1c1c1c;
        @define-color color_border #424242;
        @define-color color_border_active #6699cc;
        @define-color color_text #ffffff;
        @define-color color_urgent #8f0a0a;

        /* -- base styles -- */

        * {
          font-family: Noto Sans Nerd Font, sans-serif;
          font-size: 16px;
          border: none;
          border-radius: 0;
        }

        box, menubar, button {
          background-color: @color_bg;
          background-image: none;
          box-shadow: none;
        }

        button, label {
          color: @color_text;
        }

        button:hover {
          background-color: @color_bg_dark;
        }

        scale trough {
          min-width: 1px;
          min-height: 2px;
        }

        #bar {
          border-top: 1px solid @color_border;
        }

        .popup {
          border: 1px solid @color_border;
          padding: 1em;
        }

        /* -- bluetooth -- */
        .popup-bluetooth {
          min-height: 14em;
          min-width: 24em;
        }

        .popup-bluetooth .header {
          padding-bottom: 1.0em;
          margin-bottom: 0.6em;
          border-bottom: 1px solid @color_border;
        }

        .popup-bluetooth .header .label {
          margin-left: 0.5em;
        }

        .popup-bluetooth .disabled .spinner {
          min-width: 2.0em;
          min-height: 2.0em;
          padding: 0.4em;
        }

        .popup-bluetooth .devices .box .device {
          margin-bottom: 0.4em;
        }

        .popup-bluetooth .devices .icon {
          min-width: 2.5em;
          min-height: 2.5em;
          margin-right: 0.8em;
        }

        .popup-bluetooth .devices .box .device .status .footer-label {
          font-size: 0.8em;
        }

        .popup-bluetooth .devices .box .device .spinner {
          min-width: 1.5em;
          min-height: 1.5em;
          margin: 0.5em;
        }


        /* -- clipboard -- */

        .clipboard {
          margin-left: 5px;
          font-size: 1.1em;
        }

        .popup-clipboard .item {
          padding-bottom: 0.3em;
          border-bottom: 1px solid @color_border;
        }


        /* -- clock -- */

        .clock {
          font-weight: bold;
          margin-left: 5px;
        }

        .popup-clock .calendar-clock {
          color: @color_text;
          font-size: 2.5em;
          padding-bottom: 0.1em;
        }

        .popup-clock .calendar {
          background-color: @color_bg;
          color: @color_text;
        }

        .popup-clock .calendar .header {
          padding-top: 1em;
          border-top: 1px solid @color_border;
          font-size: 1.5em;
        }

        .popup-clock .calendar:selected {
          background-color: @color_border_active;
        }


        /* notifications */

        .notifications .count {
          font-size: 0.6rem;
          background-color: @color_text;
          color: @color_bg;
          border-radius: 100%;
          margin-right: 3px;
          margin-top: 3px;
          padding-left: 4px;
          padding-right: 4px;
          opacity: 0.7;
        }

        /* -- script -- */

        .script {
          padding-left: 10px;
        }


        /* -- sys_info -- */

        .sysinfo {
          margin-left: 10px;
        }

        .sysinfo .item {
          margin-left: 5px;
        }


        /* -- tray -- */

        .tray {
          margin-left: 10px;
        }

        /* -- volume -- */

        .popup-volume .device-box {
          border-right: 1px solid @color_border;
        }

        /* -- workspaces -- */

        .workspaces .item.focused {
          box-shadow: inset 0 -3px;
          background-color: @color_bg_dark;
        }

        .workspaces .item.urgent {
          background-color: @color_urgent;
        }

        .workspaces .item:hover {
          box-shadow: inset 0 -3px;
        }


        /* -- custom: power menu -- */

        .popup-power-menu #header {
          font-size: 1.4em;
          padding-bottom: 0.4em;
          margin-bottom: 0.6em;
          border-bottom: 1px solid @color_border;
        }

        .popup-power-menu .power-btn {
          border: 1px solid @color_border;
          padding: 0.6em 1em;
        }

        .popup-power-menu #buttons > *:nth-child(1) .power-btn {
          margin-right: 1em;
        }
      '';
    };
  };
}
