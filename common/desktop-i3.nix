# TODO: Look into https://github.com/nix-community/nixpkgs-wayland
{ config, pkgs, lib, ... }:

{
  imports = [
    ./desktop.nix
  ];

  services.xserver = {
    enable = true;
    layout = "us";
    libinput.enable = true;

    displayManager.startx.enable = true;
    displayManager.defaultSession = "none+i3"; # We startx in our home.nix
    windowManager.i3.enable = true;
  };

  environment.systemPackages = with pkgs; [
    arandr
    clipmenu
    clipnotify
    i3lock
    i3status-rust
    networkmanagerapplet
    pcmanfm
    xclip
    xdotool
    xsel
    xss-lock
  ];

  #services.clipmenu.enable = true;
  # Based on https://github.com/cdown/clipmenu/blob/develop/init/clipmenud.service
  systemd.user.services.clipmenud = {
    enable = true;
    description = "Clipmenu daemon";
    serviceConfig =  {
      Type = "simple";
      NoNewPrivileges = true;
      ProtectControlGroups = true;
      ProtectKernelTunables = true;
      RestrictRealtime = true;
      MemoryDenyWriteExecute = true;
    };
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    environment = {
      DISPLAY = ":0";
    };
    path = [ pkgs.clipmenu ];
    script = ''
      ${pkgs.clipmenu}/bin/clipmenud
    '';
  };
}
