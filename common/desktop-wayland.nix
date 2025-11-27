{ pkgs, inputs, ... }:
{
  imports = [
    ./desktop.nix
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Reduce tuigreet console spam? (Not sure if this is necessary anymore)
  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  environment.systemPackages = with pkgs; [
    wayland
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    qt5.qtwayland # for qt

    wtype # xdotool, but for wayland
    # kdePackages.xwaylandvideobridge # Portal for screen sharing
  ];

  programs.xwayland.enable = true;

  security.pam.services.swaylock = {};
  security.pam.loginLimits = [
    # Allow userland to request real-time priority, probably useful for VR?
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];
}
