{ config, pkgs, lib, ... }:

{
  imports = [
    ./desktop.nix
  ];

  services.xserver = {
    displayManager.startx.enable = true;
    desktopManager.default = "none";  # We startx in loginShellInit below
    windowManager.i3.enable = true;
  };


  # TODO: exec xcalib -d :0 "${nixpkgs}/hardware/thinkpad-x1c-hdr.icm"
  environment.loginShellInit = ''
    if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
      # Each process wraps the next process with its lifetime and environment:
      # - ssh-agent manages unlocked private keys, it dies with x11 (such as attempted xlock bypass).
      # - startx is the x11 client, it injects the display environment ($DISPLAY, etc).
      # - dbus-launch manages cross-process communication (required for GTK systray icons, etc), it requires startx's environment to function.
      # - i3 is the window manager, it also requires the startx environment.
      exec ssh-agent startx dbus-launch --exit-with-x11 i3
    fi
  '';

  environment.systemPackages = with pkgs; [
    clipmenu
    clipnotify
    i3lock
    i3status-rust
    networkmanagerapplet
    pcmanfm
    rofi
    xss-lock
  ];

  services.clipmenu.enable = true;
  # Based on https://github.com/cdown/clipmenu/blob/develop/init/clipmenud.service
  systemd.user.services.clipmenud = {
    description = "Clipmenu daemon";
    serviceConfig =  {
      Type = "simple";
      NoNewPrivileges = true;
      ProtectControlGroups = true;
      ProtectKernelTunables = true;
      RestrictRealtime = true;
      MemoryDenyWriteExecute = true;
    };
    wantedBy = [ "default.target" ];
    environment = {
      DISPLAY = ":0";
    };
    path = [ pkgs.clipmenu ];
    script = ''
      ${pkgs.clipmenu}/bin/clipmenud
    '';
  };
}
