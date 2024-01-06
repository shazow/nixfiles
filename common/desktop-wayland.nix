{ pkgs, inputs, ... }:
{
  nix.settings = {
    # Wayland binary caches
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
  };

  nixpkgs.overlays = [ inputs.nixpkgs-wayland.overlay ];

  imports = [
    ./desktop.nix
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd \"dbus-run-session sway\"";
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

    wtype                  # xdotool, but for wayland
    xwayland
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr # Backend for wayland roots
    ];
  };

  security.pam.services.swaylock = {};
  security.pam.loginLimits = [
    # Allow userland to request real-time priority, probably useful for VR?
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  programs.sway = { # Swap with hyprland
    enable = true;
    wrapperFeatures.gtk = true;

    extraPackages = with pkgs; [
      swaylock
      swayidle
      mako # Notification daemon (by swaywm creator)
    ];
  };
}
