{...}:
{
  users.users.tracy = {
    isNormalUser = true;
    home = "/home/tracy";
    uid = 1101;
  };

  home-manager.users.tracy = { pkgs, ... }: {
    home.packages = [ pkgs.steam ];
    home.stateVersion = "23.05";

    services.picom.enable = true;

    xsession = {
      enable = true;
      windowManager.command = "dbus-launch --exit-with-x11 steam -bigpicture";
    };

    programs.bash = {
      enable = true;
      profileExtra = ''
        if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
          exec startx
          systemctl suspend
        fi
      '';
    };
  };
}
