{...}:
{
  # TODO: Port to a gamekiosk module

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
      windowManager.command = "steam -bigpicture";
    };

    home.file.".xinitrc".text = ''
      xrandr --output DisplayPort-0 --primary --mode 3840x2160 --pos 0x0 --rotate normal
    '';

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
