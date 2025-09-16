{ pkgs, config, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "wlr/workspaces" "window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "disk" "battery" "backlight" "gammastep" "tray" ];

        "wlr/workspaces" = {
          all-outputs = true;
          on-click = "activate";
        };

        window = {
          format = "{}";
          max-length = 50;
        };

        clock = {
          format = " {:%a %Y-%m-%d %l:%M%p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " Muted";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" ""];
          };
        };

        network = {
          format-wifi = " {essid} ({signalStrength}%)";
          format-ethernet = " {ipaddr}/{cidr}";
          format-disconnected = "Disconnected";
          tooltip-format = "{ifname} via {gwaddr}";
        };

        cpu = {
          format = " {usage}%";
          tooltip = true;
        };

        memory = {
          format = " {}%";
        };

        temperature = {
          thermal-zone = 0;
          format = " {temperatureC}°C";
        };

        disk = {
          path = "/";
          format = " {free}";
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = ["" "" "" "" ""];
        };

        backlight = {
          format = " {percent}%";
        };

        gammastep = {
            format = "{icon} {temperature}K";
            format-icons = {
                "day" = "";
                "night" = "";
            };
        };

        tray = {
          icon-size = 21;
          spacing = 10;
        };
      };
    };
    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: DejaVu Sans Mono, FontAwesome;
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background: #222222;
          color: #dddddd;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #dddddd;
      }

      #workspaces button.focused {
          background: #444444;
      }

      #workspaces button.urgent {
          background: #900000;
      }

      #mode {
          background: #444444;
          border-bottom: 3px solid #dddddd;
      }

      #clock, #battery, #cpu, #memory, #temperature, #disk, #pulseaudio, #network, #backlight, #gammastep, #window, #tray {
          padding: 0 10px;
          margin: 0 5px;
          color: #dddddd;
      }
    '';
  };
}
