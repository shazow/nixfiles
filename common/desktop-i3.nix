{ config, pkgs, lib, ... }:

{
  imports = [
    ./desktop.nix
  ];

  services.xserver = {
    displayManager.startx.enable = true;
    desktopManager.default = "none";  # We startx in our home.nix
    windowManager.i3.enable = true;
  };

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
