{
  head = ''
    theme = "solarized-dark"

    [icons]
    name = "awesome"

    [[block]]
    block = "focused_window"

    [[block]]
    block = "net"
    device = "wlp2s0"
    ssid = true
    ip = true
    interval = 30
    speed_up = false
    speed_down = false

    [[block]]
    block = "disk_space"
    path = "/"
    alias = "/"
    info_type = "available"
    unit = "GB"
    interval = 120
    warning = 20.0
    alert = 10.0

    [[block]]
    block = "memory"
    display_type = "memory"
    format_mem = "{Mup}%"
    format_swap = "{SUp}%"
    interval = 5
    clickable = true
    warning_mem = 80
    warning_swap = 80
    critical_mem = 95
    critical_swap = 95

    [[block]]
    block = "cpu"
    interval = 2
    frequency = true

    [[block]]
    block = "temperature"
    collapsed = false
    interval = 20
    format = "{min}~{max}°"
    chip = "coretemp-*"
  '';

  laptop = ''
    [[block]]
    block = "battery"
    interval = 10
    show = "both"

    [[block]]
    block = "backlight"
  '';

  tail = ''
    [[block]]
    block = "toggle"
    command_state = "systemctl --user -q is-active redshift && echo on"
    command_on = "systemctl --user start redshift"
    command_off = "systemctl --user stop redshift"
    text = "R"
    interval = 60

    [[block]]
    block = "sound"

    [[block]]
    block = "time"
    interval = 10
    format = "%a %Y-%m-%d %l:%M%p"
  '';
}
