{ pkgs, ... }:

{
  # TODO: Redo with something like https://github.com/mxkrsv/dotfiles-old/blob/master/.config/waybar/config?
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";

        modules-left = [
          "network#wifi"
          "network#ethernet"
        ];

        modules-center = [
          "niri/window"
        ];

        modules-right = [
          "disk"
          "memory"
          "cpu"
          "temperature"
          "battery"
          "backlight"
          "pulseaudio"
          "clock"
          "tray"
        ];

        "niri/window" = {
          format = "{}";
          max-length = 50;
        };

        "network#wifi" = {
          interface = "wlan0";
          format-wifi = " {essid} ({ipaddr})";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr} ";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        "network#ethernet" = {
          interface = "eno1";
          format-linked = " {ipaddr}";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr} ";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        disk = {
          interval = 120;
          format = " {free}";
          path = "/";
          on-click = "${pkgs.gnome-disk-utility}/bin/gnome-disks";
        };

        memory = {
          interval = 5;
          format = " {}%";
          on-click = "${pkgs.gnome-system-monitor}/bin/gnome-system-monitor";
        };

        cpu = {
          interval = 2;
          format = " {usage}% ({avg_frequency}GHz)";
          on-click = "${pkgs.gnome-system-monitor}/bin/gnome-system-monitor";
        };

        temperature = {
          interval = 20;
          format = " {temperatureC}°C";
          # NOTE: The hwmon path can sometimes change on reboot.
          # You may need to find a more stable path or use a different method if you encounter issues.
          # For example: `thermal_zone = 0;` might work.
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
        };

        battery = {
          interval = 10;
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = ["" "" "" "" ""];
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = ["" "" "" "" "" "" "" "" ""];
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          format-icons = {
            headphone = "";
            "hands-free" = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
        };

        clock = {
          interval = 10;
          format = " {:%a %Y-%m-%d %l:%M %p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };


    style = ''
      window#waybar {
          background: #002b36;
          color: #839496;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #839496;
      }

      #workspaces button.focused {
          color: #268bd2;
      }

      #workspaces button:hover {
          background: #073642;
          color: #93a1a1;
      }

      #mode {
          background: #cb4b16;
          color: #fdf6e3;
      }

      #clock, #battery, #cpu, #memory, #disk, #temperature, #backlight, #network, #pulseaudio, #window {
          padding: 0 10px;
          margin: 0 5px;
      }
    '';
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    font-awesome # For the icons
    noto-fonts # A good fallback font
  ];
}

