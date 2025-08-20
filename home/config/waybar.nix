# Waybar configuration for Niri
# Replaces i3status-rust from Sway setup
{
  pkgs,
  lib,
  ...
}:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ ];
        modules-right = [
          "network#wifi"
          "network#ethernet"
          "disk"
          "memory"
          "cpu"
          "temperature"
          "battery"
          "backlight"
          "pulseaudio"
          "clock"
        ];
        
        # Niri workspaces
        "niri/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
          warp-on-scroll = false;
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "6" = "";
            "7" = "";
            "8" = "";
            "9" = "";
            "10" = "";
            focused = "";
            default = "";
          };
        };
        
        # Focused window (replaces focused_window block)
        "niri/window" = {
          format = "{}";
          max-length = 50;
          separate-outputs = true;
        };
        
        # WiFi network (replaces net block for wlp2s0)
        "network#wifi" = {
          interface = "wlp2s0";
          format-wifi = " {essid} {ipaddr}";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
          interval = 30;
        };
        
        # Ethernet network (replaces net block for enp0s31f6)
        "network#ethernet" = {
          interface = "enp0s31f6";
          format-ethernet = " {ipaddr}";
          format-disconnected = "";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-disconnected = "Disconnected";
          interval = 30;
        };
        
        # Disk space (replaces disk_space block)
        disk = {
          path = "/";
          format = " {used}/{total}";
          interval = 120;
          states = {
            warning = 80;
            critical = 90;
          };
        };
        
        # Memory usage (replaces memory block)
        memory = {
          format = " {percentage}%";
          interval = 5;
          states = {
            warning = 80;
            critical = 95;
          };
        };
        
        # CPU usage (replaces cpu block)
        cpu = {
          format = " {usage}%";
          interval = 2;
          states = {
            warning = 70;
            critical = 90;
          };
        };
        
        # Temperature (replaces temperature block)
        temperature = {
          format = " {temperatureC}°C";
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          interval = 20;
        };
        
        # Battery (replaces battery block)
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}% {time}";
          format-charging = " {capacity}% {time}";
          format-plugged = " {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [ "" "" "" "" "" ];
          interval = 10;
        };
        
        # Backlight (replaces backlight block)
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
          on-scroll-up = "brightness up 5";
          on-scroll-down = "brightness down 5";
        };
        
        # Audio (replaces sound block)
        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-bluetooth-muted = " {icon}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pamixer --toggle-mute";
          on-click-right = "pavucontrol";
          on-scroll-up = "volumectl up";
          on-scroll-down = "volumectl down";
        };
        
        # Clock (replaces time block)
        clock = {
          format = " {:%a %Y-%m-%d %l:%M%p}";
          tooltip-format = "{:%Y-%m-%d | %H:%M}";
          interval = 10;
        };
      };
    };
    
    # Waybar CSS styling
    style = ''
      * {
        font-family: "DejaVu Sans Mono", "FontAwesome", monospace;
        font-size: 12px;
        color: #dddddd;
      }
      
      window#waybar {
        background-color: #222222;
        border-bottom: 3px solid #222222;
      }
      
      #workspaces {
        background-color: #333333;
        margin: 0 4px;
        border-radius: 4px;
      }
      
      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #dddddd;
        border: none;
        border-radius: 4px;
      }
      
      #workspaces button:hover {
        background-color: #555555;
      }
      
      #workspaces button.focused {
        background-color: #666666;
        color: #ffffff;
      }
      
      #window {
        margin: 0 4px;
        padding: 0 8px;
        background-color: #333333;
        border-radius: 4px;
      }
      
      #network,
      #disk,
      #memory,
      #cpu,
      #temperature,
      #battery,
      #backlight,
      #pulseaudio,
      #clock {
        padding: 0 8px;
        margin: 0 2px;
        background-color: #333333;
        border-radius: 4px;
      }
      
      #network.disconnected {
        color: #666666;
      }
      
      #memory.warning {
        color: #f1c40f;
      }
      
      #memory.critical {
        color: #e74c3c;
        animation: blink 0.5s linear infinite alternate;
      }
      
      #cpu.warning {
        color: #f1c40f;
      }
      
      #cpu.critical {
        color: #e74c3c;
        animation: blink 0.5s linear infinite alternate;
      }
      
      #temperature.critical {
        color: #e74c3c;
        animation: blink 0.5s linear infinite alternate;
      }
      
      #battery.warning:not(.charging) {
        color: #f1c40f;
      }
      
      #battery.critical:not(.charging) {
        color: #e74c3c;
        animation: blink 0.5s linear infinite alternate;
      }
      
      @keyframes blink {
        to {
          opacity: 0.5;
        }
      }
    '';
  };
}
