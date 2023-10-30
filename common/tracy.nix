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

    programs.bash.enable = true;
    programs.bash.profileExtra = ''
      if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
        exec steam -bigpicture
        systemctl suspend
      fi
    '';
  };
}
